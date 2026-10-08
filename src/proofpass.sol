// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

contract ProofPass {
    address public organizer;

    struct Event {
        uint256 eventId;
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        string location;
        string status;
    }

    uint256 public nextEventId;
    mapping(uint256 => Event) public events;

    address[] public participants;

    event ParticipantRegistered(address attendee);
    event ParticipantUpdated(address oldAttendee, address newAttendee);
    event ParticipantRemoved(address attendee);
    event EventStatusUpdated(uint256 eventId, string newStatus);
    event EventCreated(uint256 eventId, string name);

    constructor() {
        organizer = msg.sender;
    }

    function registerParticipant(address attendee) public {
        require(msg.sender == organizer, "Only the organizer can register participants.");
        require(attendee != address(0), "Invalid attendee address.");
        require(!isRegistered(attendee), "Participant already registered.");

        participants.push(attendee);

        emit ParticipantRegistered(attendee);
    }

    function isRegistered(address attendee) public view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == attendee) {
                return true;
            }
        }

        return false;
    }

    function updateParticipant(address oldAttendee, address newAttendee) public {
        require(msg.sender == organizer, "Only the organizer can update participants.");
        require(newAttendee != address(0), "Invalid attendee address.");
        require(oldAttendee != newAttendee, "Old and new attendee cannot be the same.");
        require(!isRegistered(newAttendee), "Participant already registered.");

        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == oldAttendee) {
                participants[i] = newAttendee;

                emit ParticipantUpdated(oldAttendee, newAttendee);

                return;
            }
        }

        revert("Old attendee not found.");
    }

    function removeParticipant(address attendee) external {
        require(msg.sender == organizer, "Only the organizer can remove participants.");

        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == attendee) {
                participants[i] = participants[participants.length - 1];
                participants.pop();

                emit ParticipantRemoved(attendee);

                return;
            }
        }

        revert("Attendee not found.");
    }

    function getParticipants() external view returns (address[] memory) {
        return participants;
    }

    function updateEventStatus(uint256 eventId, string memory newStatus) external {
        require(msg.sender == organizer, "Only the organizer can update event status.");
        require(bytes(newStatus).length > 0, "Event status cannot be empty.");
        require(eventId < nextEventId, "Event does not exist.");

        events[eventId].status = newStatus;

        emit EventStatusUpdated(eventId, newStatus);
    }

    function createEvent(
        string memory name,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        string memory location,
        string memory status
    ) external {
        require(msg.sender == organizer, "Only the organizer can create events.");
        require(bytes(status).length > 0, "Event status cannot be empty.");
        require(bytes(name).length > 0, "Event name cannot be empty.");
        require(bytes(description).length > 0, "Event description cannot be empty.");
        require(startTime < endTime, "Invalid event time.");

        events[nextEventId] = Event({
            eventId: nextEventId,
            name: name,
            description: description,
            startTime: startTime,
            endTime: endTime,
            location: location,
            status: status
        });

        emit EventCreated(nextEventId, name);

        nextEventId++;
    }
}
