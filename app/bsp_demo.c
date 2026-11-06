#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>

int main(int argc, char **argv)
{
    struct utsname info;
    double uptime = 0.0;
    const char *mode = argc == 2 ? argv[1] : "manual";
    if (argc > 2 || (strcmp(mode, "manual") && strcmp(mode, "autostart"))) {
        fprintf(stderr, "usage: %s [manual|autostart]\n", argv[0]);
        return 2;
    }
    if (uname(&info) < 0) {
        perror("uname");
        return 1;
    }
    FILE *fp = fopen("/proc/uptime", "r");
    if (!fp) {
        perror("/proc/uptime (proc must be mounted)");
        return 1;
    }
    int count = fscanf(fp, "%lf", &uptime);
    fclose(fp);
    if (count != 1) {
        fputs("cannot parse /proc/uptime\n", stderr);
        return 1;
    }
    printf("[BSP_DEMO] started mode=%s\n", mode);
    printf("[BSP_DEMO] machine=%s kernel=%s uptime=%.2f seconds\n",
           info.machine, info.release, uptime);
    return 0;
}
