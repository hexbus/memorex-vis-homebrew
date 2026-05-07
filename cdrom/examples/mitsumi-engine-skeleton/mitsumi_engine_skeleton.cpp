// Minimal Mitsumi target-engine skeleton for VIS CD-ROM replacement research.
// This is a design scaffold, not finished firmware.

#include <stdint.h>

enum State {
    IDLE,
    PACKET_RECEIVE,
    STATUS_READY,
    DATA_OUT,
    READ_ACTIVE,
    ERROR_STATE
};

struct Packet {
    uint8_t bytes[8];
    uint8_t length;
    uint8_t expected;
};

static State state = IDLE;
static Packet packet;
static uint8_t status_byte = 0x40;
static uint8_t phase_byte = 0x0B;
static uint32_t read_lba = 0;
static uint8_t read_count = 0;

static uint8_t from_bcd(uint8_t v) {
    return ((v >> 4) * 10) + (v & 0x0f);
}

static uint32_t msf_to_lba(uint8_t m, uint8_t s, uint8_t f) {
    uint32_t frames = (uint32_t)from_bcd(m) * 60U * 75U
                    + (uint32_t)from_bcd(s) * 75U
                    + (uint32_t)from_bcd(f);
    return frames >= 150 ? frames - 150 : 0;
}

static uint8_t expected_length(uint8_t cmd) {
    switch (cmd) {
        case 0x40: return 1; // status
        case 0x50: return 2; // set mode
        case 0x70: return 1; // hold/pause
        case 0x90: return 3; // configure: observed 90 04 xx
        case 0x10: return 1; // TOC/disk info, refine later
        case 0xDC: return 1; // version
        case 0xC0: return 7; // C0 M S F 00 00 count
        case 0xF6: return 1; // eject
        case 0xF8: return 1; // close tray
        case 0xFE: return 2; // lock/unlock
        default:   return 1; // permissive for prototype
    }
}

static void execute_packet() {
    switch (packet.bytes[0]) {
        case 0x40: // status
            status_byte = 0x40;
            phase_byte = 0x0B;
            state = STATUS_READY;
            break;

        case 0x50: // set mode
        case 0x70: // hold
        case 0x90: // configure
            status_byte = 0x40;
            phase_byte = 0x0B;
            state = STATUS_READY;
            break;

        case 0x10: // TOC/disk info
        case 0xDC: // version
            status_byte = 0x40;
            phase_byte = 0x0B;
            state = DATA_OUT;
            break;

        case 0xC0: // read
            read_lba = msf_to_lba(packet.bytes[1], packet.bytes[2], packet.bytes[3]);
            read_count = packet.bytes[6] ? packet.bytes[6] : 1;
            status_byte = 0x40;
            phase_byte = 0x0B;
            state = READ_ACTIVE;
            break;

        default:
            status_byte = 0x40;
            phase_byte = 0x0B;
            state = STATUS_READY;
            break;
    }
}

// Called when host writes selected data/command register.
void mitsumi_write_data(uint8_t value) {
    if (state != PACKET_RECEIVE) {
        packet = {};
        packet.bytes[0] = value;
        packet.length = 1;
        packet.expected = expected_length(value);
        state = PACKET_RECEIVE;
    } else if (packet.length < sizeof(packet.bytes)) {
        packet.bytes[packet.length++] = value;
    }

    if (packet.length >= packet.expected) {
        execute_packet();
    }
}

// Called when host reads selected register.
uint8_t mitsumi_read_register(uint8_t reg) {
    if (reg == 0) {
        // TODO: return queued response byte or sector byte.
        return status_byte;
    }

    // Status/phase register candidate.
    return phase_byte;
}
