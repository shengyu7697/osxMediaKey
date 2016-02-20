#import <IOKit/hidsystem/IOHIDLib.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import <stdio.h>
#import <strings.h>

void usage(char *process_name)
{
    printf("%s [brightnessdown|brightnessup|rewind|play|fast|mute|voldown|volup]\n", process_name);
}

int main(int argc, char *argv[]) {
    mach_port_t connect = 0;
    mach_port_t master_port;
    mach_port_t service;
    mach_port_t iter;

    IOMasterPort(bootstrap_port, &master_port);
    IOServiceGetMatchingServices(master_port, IOServiceMatching(kIOHIDSystemClass), &iter);

    service = IOIteratorNext(iter);
    IOObjectRelease(iter);

    IOServiceOpen(service, mach_task_self(), kIOHIDParamConnectType, &connect);
    IOObjectRelease(service);

    IOGPoint location = {0, 0};
    NXEventData eventData;

    if (argc != 2) {
        usage(argv[0]);
        return 1;
    }

    SInt32 key = NX_KEYTYPE_VIDMIRROR;
    char *str = argv[1];

    if (strcmp(str, "brightnessdown") == 0) {
        key = NX_KEYTYPE_BRIGHTNESS_DOWN;
    } else if (strcmp(str, "brightnessup") == 0) {
        key = NX_KEYTYPE_BRIGHTNESS_UP;
    } else if (strcmp(str, "rewind") == 0) {
        key = NX_KEYTYPE_REWIND;
    } else if (strcmp(str, "play") == 0) {
        key = NX_KEYTYPE_PLAY;
    } else if (strcmp(str, "fast") == 0) {
        key = NX_KEYTYPE_FAST;
    } else if (strcmp(str, "mute") == 0) {
        key = NX_KEYTYPE_MUTE;
    } else if (strcmp(str, "voldown") == 0) {
        key = NX_KEYTYPE_SOUND_DOWN;
    } else if (strcmp(str, "volup") == 0) {
        key = NX_KEYTYPE_SOUND_UP;
    } else {
        usage(argv[0]);
        return 1;
    }

    bzero(&eventData, sizeof(NXEventData));
    eventData.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    eventData.compound.misc.L[0] = key << 16 | NX_KEYDOWN << 8;
    IOHIDPostEvent(connect, NX_SYSDEFINED, location, &eventData, kNXEventDataVersion, 0, FALSE);

    bzero(&eventData, sizeof(NXEventData));
    eventData.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    eventData.compound.misc.L[0] = key << 16 | NX_KEYUP << 8;
    IOHIDPostEvent(connect, NX_SYSDEFINED, location, &eventData, kNXEventDataVersion, 0, FALSE);

    return 0;
}
