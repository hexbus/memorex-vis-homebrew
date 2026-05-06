// Mitsumi proprietary CD-ROM target skeleton for VIS replacement research.
// This is a design skeleton, not finished firmware.
//
// Goal:
//   Replace a SCSI target engine with a Mitsumi 40-pin CD-ROM target engine.
//
// VIS ROM expects, at minimum:
//   0x40 status
//   0x50 set drive mode
//   0x70 hold/pause
//   0x90 configure
//   0x10 TOC / disk info
//   0xDC version
//   0xC0 read sector packet: C0 M S F 00 00 count

#include <stdint.h>
#include <stddef.h>

enum MitsumiState {
    MITSUMI_IDLE,
    MITSUMI_PACKET_RECEIVE,
    MITSUMI_STATUS_READY,
    MITSUMI_DATA_OUT,
    MITSUMI_READ_ACTIVE,
    MITSUMI_ERROR
};

struct MitsumiPacket {
    uint8_t bytes[8];
    uint8_t length;
    uint8_t expected;
};

class MitsumiEngine {
public:
    void reset();
    void writeRegister(uint8_t reg, uint8_t value);
    uint8_t readRegister(uint8_t reg);
    void tick();

private:
    MitsumiState state = MITSUMI_IDLE;
    MitsumiPacket packet{};
    uint8_t status = 0x40;
    uint8_t phase = 0x0B;

    uint32_t readLba = 0;
    uint16_t readRemaining = 0;
    uint16_t sectorOffset = 0;

    void startPacket(uint8_t command);
    void appendPacket(uint8_t value);
    void executePacket();

    void cmdStatus();
    void cmdSetMode();
    void cmdConfigure();
    void cmdToc();
    void cmdVersion();
    void cmdReadC0();

    static uint8_t fromBcd(uint8_t value);
    static uint32_t msfToLba(uint8_t m, uint8_t s, uint8_t f);
};

void MitsumiEngine::reset() {
    state = MITSUMI_IDLE;
    packet = {};
    status = 0x40;
    phase = 0x0B;
    readLba = 0;
    readRemaining = 0;
    sectorOffset = 0;
}

void MitsumiEngine::writeRegister(uint8_t reg, uint8_t value) {
    // Working model:
    // reg 0 = command/data register selected by HA0/HA1.
    // Other registers need refinement once bus behavior is verified.

    if (reg != 0) {
        return;
    }

    if (state != MITSUMI_PACKET_RECEIVE) {
        startPacket(value);
    } else {
        appendPacket(value);
    }
}

uint8_t MitsumiEngine::readRegister(uint8_t reg) {
    if (reg == 0) {
        // Data / response register.
        // TODO: return queued response byte or sector byte.
        return status;
    }

    if (reg == 1 || reg == 3) {
        // Status / phase register candidate.
        return phase;
    }

    return 0xFF;
}

void MitsumiEngine::tick() {
    // TODO:
    // - update IRQ/DRQ based on state
    // - handle sector streaming
    // - track host reads
    // - advance phase/status
}

void MitsumiEngine::startPacket(uint8_t command) {
    packet = {};
    packet.bytes[0] = command;
    packet.length = 1;

    switch (command) {
        case 0x40: packet.expected = 1; break; // status
        case 0x50: packet.expected = 2; break; // set mode
        case 0x70: packet.expected = 1; break; // hold/pause
        case 0x90: packet.expected = 3; break; // configure: observed 90 04 xx
        case 0x10: packet.expected = 1; break; // TOC/info, refine later
        case 0xDC: packet.expected = 1; break; // version
        case 0xC0: packet.expected = 7; break; // read: C0 M S F 00 00 count
        case 0xFE: packet.expected = 2; break; // lock/unlock
        case 0xF6: packet.expected = 1; break; // eject
        case 0xF8: packet.expected = 1; break; // close tray
        default:   packet.expected = 1; break;
    }

    state = MITSUMI_PACKET_RECEIVE;

    if (packet.length >= packet.expected) {
        executePacket();
    }
}

void MitsumiEngine::appendPacket(uint8_t value) {
    if (packet.length < sizeof(packet.bytes)) {
        packet.bytes[packet.length++] = value;
    }

    if (packet.length >= packet.expected) {
        executePacket();
    }
}

void MitsumiEngine::executePacket() {
    switch (packet.bytes[0]) {
        case 0x40: cmdStatus(); break;
        case 0x50: cmdSetMode(); break;
        case 0x90: cmdConfigure(); break;
        case 0x10: cmdToc(); break;
        case 0xDC: cmdVersion(); break;
        case 0xC0: cmdReadC0(); break;

        // For first prototype, accept no-op control commands.
        case 0x70:
        case 0xF6:
        case 0xF8:
        case 0xFE:
            status = 0x40;
            phase = 0x0B;
            state = MITSUMI_STATUS_READY;
            break;

        default:
            // Be permissive at first; log unknown commands in real firmware.
            status = 0x40;
            phase = 0x0B;
            state = MITSUMI_STATUS_READY;
            break;
    }
}

void MitsumiEngine::cmdStatus() {
    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_STATUS_READY;
}

void MitsumiEngine::cmdSetMode() {
    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_STATUS_READY;
}

void MitsumiEngine::cmdConfigure() {
    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_STATUS_READY;
}

void MitsumiEngine::cmdVersion() {
    // TODO: queue plausible Mitsumi/Gryphon version response bytes.
    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_DATA_OUT;
}

void MitsumiEngine::cmdToc() {
    // TODO: queue one-track data TOC / disk-info response.
    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_DATA_OUT;
}

void MitsumiEngine::cmdReadC0() {
    readLba = msfToLba(packet.bytes[1], packet.bytes[2], packet.bytes[3]);
    readRemaining = packet.bytes[6] == 0 ? 1 : packet.bytes[6];
    sectorOffset = 0;

    status = 0x40;
    phase = 0x0B;
    state = MITSUMI_READ_ACTIVE;

    // TODO:
    // - seek ISO to readLba * 2048
    // - prepare readRemaining sectors
    // - assert IRQ/DRQ/phase in the way VIS expects
}

uint8_t MitsumiEngine::fromBcd(uint8_t value) {
    return ((value >> 4) * 10) + (value & 0x0F);
}

uint32_t MitsumiEngine::msfToLba(uint8_t m, uint8_t s, uint8_t f) {
    uint32_t frames =
        (uint32_t)fromBcd(m) * 60U * 75U +
        (uint32_t)fromBcd(s) * 75U +
        (uint32_t)fromBcd(f);

    return frames >= 150 ? frames - 150 : 0;
}
