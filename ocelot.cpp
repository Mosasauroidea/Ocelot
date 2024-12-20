#include <fstream>
#include <iostream>
#include <csignal>
#include <thread>
#include <execinfo.h>
#include <glog/logging.h>
#include <libgen.h>
#include "ocelot.h"
#include "config.h"
#include "db.h"
#include "worker.h"
#include "events.h"
#include "schedule.h"
#include "site_comm.h"
#include "version.h"

static connection_mother *mother;
static worker *work;
static mysql *db;
static site_comm *sc;
static config *conf;
static schedule *sched;

struct stats_t stats;

static void sig_handler(int sig) {
	if (sig == SIGINT || sig == SIGTERM) {
		LOG(INFO) << "Caught SIGINT/SIGTERM";
		if (work->shutdown()) {
			exit(0);
		}
    } else if (sig == SIGSEGV || sig == SIGABRT) {
        void *array[10];
        size_t size = backtrace(array, 10);

		LOG(ERROR) << "Caught SIGSEGV/SIGABRT " << sig;
        backtrace_symbols_fd(array, size, STDERR_FILENO);
        if (work->shutdown()) {
            exit(0);
        }
    } else if (sig == SIGHUP) {
		LOG(INFO) << "Reloading config";
		LOG(INFO).flush();
		conf->reload();
		db->reload_config(conf);
		mother->reload_config(conf);
		sc->reload_config(conf);
		sched->reload_config(conf);
		work->reload_config(conf);
		LOG(INFO) << "Done reloading config";
	} else if (sig == SIGUSR1) {
		LOG(INFO) << "Reloading from database";
		std::thread w_thread(&worker::reload_lists, work);
		w_thread.detach();
	}
}

int main(int argc, char **argv) {
	// we don't use printf so make cout/cerr a little bit faster
	std::ios_base::sync_with_stdio(false);

	conf = new config();
	bool verbose = false, conf_arg = false;
	std::string conf_file_path("./ocelot.conf");
	for (int i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-v")) {
			verbose = true;
		} else if (!strcmp(argv[i], "-c") && i < argc - 1) {
			conf_arg = true;
			conf_file_path = argv[++i];
		} else {
			std::cout << "Usage: " << argv[0] << " [-v] [-c configfile]" << std::endl;
			return 0;
		}
	}

	std::ifstream conf_file(conf_file_path);
	if (conf_file.fail()) {
		std::cout << "Using default config because '" << conf_file_path << "' couldn't be opened" << std::endl;
		if (!conf_arg) {
			std::cout << "Start Ocelot with -c <path> to specify config file if necessary" << std::endl;
		}
	} else {
		conf->load(conf_file_path, conf_file);
	}

	// Initialize Google’s logging library
#if defined(__DEBUG_BUILD__)
	FLAGS_alsologtostderr = true;
#endif
	std::string log_dir = conf->get_str("log_dir");
	FLAGS_log_dir = log_dir;
	google::InitGoogleLogging(argv[0]);
	google::FlushLogFiles(google::ERROR);

	std::cout << "Ocelot has been started! Check logging files with prefix "<< basename(argv[0]) << " in "
		<< log_dir << " for details." << std::endl;
	LOG(INFO) << "Ocelot version: " << version << "\n";

	db = new mysql(conf);

	if (!db->connected()) {
		LOG(INFO) << "Exiting...";
		return 0;
	}

	db->verbose_flush = verbose;

	sc = new site_comm(conf);
	sc->verbose_flush = verbose;

	user_list users_list;
	torrent_list torrents_list;
	std::vector<std::string> whitelist;
	db->load_users(users_list);
	db->load_torrents(torrents_list);
	db->load_whitelist(whitelist);

	stats.open_connections = 0;
	stats.opened_connections = 0;
	stats.connection_rate = 0;
	stats.requests = 0;
	stats.request_rate = 0;
	stats.leechers = 0;
	stats.seeders = 0;
	stats.announcements = 0;
	stats.succ_announcements = 0;
	stats.scrapes = 0;
	stats.bytes_read = 0;
	stats.bytes_written = 0;
	stats.start_time = time(nullptr);

	// Create worker object, which handles announces and scrapes and all that jazz
	work = new worker(conf, torrents_list, users_list, whitelist, db, sc);

	// Create schedule object
	sched = new schedule(conf, work, db, sc);

	// Create connection mother, which binds to its socket and handles the event stuff
	mother = new connection_mother(conf, work, db, sc, sched);

	// Add signal handlers now that all objects have been created
	struct sigaction handler, ignore;
	ignore.sa_handler = SIG_IGN;
	handler.sa_handler = sig_handler;
	sigemptyset(&handler.sa_mask);
	handler.sa_flags = 0;

	sigaction(SIGINT, &handler, nullptr);
	sigaction(SIGTERM, &handler, nullptr);
	sigaction(SIGSEGV, &handler, nullptr);
	sigaction(SIGABRT, &handler, nullptr);
	sigaction(SIGHUP, &handler, nullptr);
	sigaction(SIGUSR1, &handler, nullptr);
	sigaction(SIGUSR2, &ignore, nullptr);

	mother->run();

	return 0;
}
