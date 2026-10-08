// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {ProofPass} from "../src/proofpass.sol";

contract ProofPassTest is Test {
    ProofPass proofPass;

    function setUp() public {
        proofPass = new ProofPass();
    }

    function testCreateEvent() public {
        proofPass.createEvent(
            "web3 conference",
            "A blockchain Conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "New York",
            "open"
        );

        (
            uint256 eventId,
            string memory name,
            string memory description,
            uint256 startTime,
            uint256 endTime,
            string memory location,
            string memory status
        ) = proofPass.events(0);

        assertEq(eventId, 0);
        assertEq(name, "web3 conference");
        assertEq(description, "A blockchain Conference");
        assertEq(location, "New York");
        assertEq(status, "open");
    }

    function testRegisterParticipant() public {
        address attendee = address(0x123);

        proofPass.registerParticipant(attendee);

        assertTrue(proofPass.isRegistered(attendee));
    }

    function testCannotRegisterParticipantTwice() public {
        address attendee = address(0x123);

        proofPass.registerParticipant(attendee);

        vm.expectRevert("Participant already registered.");
        proofPass.registerParticipant(attendee);
    }

    function testUpdateParticipant() public {
        address oldAttendee = address(0x123);
        address newAttendee = address(0x456);

        proofPass.registerParticipant(oldAttendee);

        proofPass.updateParticipant(oldAttendee, newAttendee);

        assertTrue(proofPass.isRegistered(newAttendee));
        assertFalse(proofPass.isRegistered(oldAttendee));
    }

    function testRemoveParticipant() public {
        address attendee = address(0x123);

        proofPass.registerParticipant(attendee);

        proofPass.removeParticipant(attendee);

        assertFalse(proofPass.isRegistered(attendee));
    }

    function testUpdateEventStatus() public {
        proofPass.createEvent(
            "web3 conference",
            "A blockchain Conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "New York",
            "open"
        );

        proofPass.updateEventStatus(0, "closed");

        (,,,,,, string memory status) = proofPass.events(0);

        assertEq(status, "closed");
    }

    function testNonOrganizerCannotRegisterParticipant() public {
        address attendee = address(0x123);
        address nonOrganizer = address(0x456);

        vm.prank(nonOrganizer);

        vm.expectRevert("Only the organizer can register participants.");
        proofPass.registerParticipant(attendee);
    }

    function testNonOrganizerCannotCreateEvent() public {
        address nonOrganizer = address(0x456);

        vm.prank(nonOrganizer);

        vm.expectRevert("Only the organizer can create events.");
        proofPass.createEvent(
            "web3 conference",
            "A blockchain Conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "New York",
            "open"
        );
    }

    function testNonOrganizerCannotUpdateEventStatus() public {
        proofPass.createEvent(
            "web3 conference",
            "A blockchain Conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "New York",
            "open"
        );

        address nonOrganizer = address(0x456);

        vm.prank(nonOrganizer);

        vm.expectRevert("Only the organizer can update event status.");
        proofPass.updateEventStatus(0, "closed");
    }

    function testNonOrganizerCannotRemoveParticipant() public {
        address attendee = address(0x123);
        proofPass.registerParticipant(attendee);

        address nonOrganizer = address(0x456);

        vm.prank(nonOrganizer);

        vm.expectRevert("Only the organizer can remove participants.");
        proofPass.removeParticipant(attendee);
    }

    function testCannotCreateEventWithInvalidTime() public {
        vm.expectRevert("Invalid event time.");

        proofPass.createEvent(
            "web3 conference",
            "A blockchain Conference",
            block.timestamp + 2 days,
            block.timestamp + 1 days,
            "New York",
            "open"
        );
    }

    function testCannotUpdateNonexistentParticipant() public {
        address oldAttendee = address(0x123);
        address newAttendee = address(0x456);

        vm.expectRevert("Old attendee not found.");
        proofPass.updateParticipant(oldAttendee, newAttendee);
    }

    function testCannotRemoveNonexistentParticipant() public {
        address attendee = address(0x123);

        vm.expectRevert("Attendee not found.");
        proofPass.removeParticipant(attendee);
    }

    function testCannotUpdateParticipantToExistingAddress() public {
        address firstAttendee = address(0x123);
        address secondAttendee = address(0x456);

        proofPass.registerParticipant(firstAttendee);
        proofPass.registerParticipant(secondAttendee);

        vm.expectRevert("Participant already registered.");
        proofPass.updateParticipant(firstAttendee, secondAttendee);
    }

    function testCannotUpdateParticipantToZeroAddress() public {
        address attendee = address(0x123);

        proofPass.registerParticipant(attendee);

        vm.expectRevert("Invalid attendee address.");
        proofPass.updateParticipant(attendee, address(0));
    }

    function testCannotRegisterZeroAddress() public {
        vm.expectRevert("Invalid attendee address.");

        proofPass.registerParticipant(address(0));
    }

    function testCannotUpdateNonexistentEvent() public {
        vm.expectRevert("Event does not exist.");

        proofPass.updateEventStatus(999, "closed");
    }

    function testEventIdsIncrement() public {
        proofPass.createEvent(
            "Event One", "First event", block.timestamp + 1 days, block.timestamp + 2 days, "New York", "open"
        );

        proofPass.createEvent(
            "Event Two", "Second event", block.timestamp + 3 days, block.timestamp + 4 days, "London", "open"
        );

        assertEq(proofPass.nextEventId(), 2);

        (uint256 firstEventId, string memory firstName,,,,,) = proofPass.events(0);

        assertEq(firstEventId, 0);
        assertEq(firstName, "Event One");

        (uint256 secondEventId, string memory secondName,,,,,) = proofPass.events(1);

        assertEq(secondEventId, 1);
        assertEq(secondName, "Event Two");
    }

    function testGetParticipants() public {
        address firstAttendee = address(0x123);
        address secondAttendee = address(0x456);

        proofPass.registerParticipant(firstAttendee);
        proofPass.registerParticipant(secondAttendee);

        address[] memory participantList = proofPass.getParticipants();

        assertEq(participantList.length, 2);
        assertEq(participantList[0], firstAttendee);
        assertEq(participantList[1], secondAttendee);
    }

    function testCannotCreateEventWithEmptyName() public {
        vm.expectRevert("Event name cannot be empty.");

        proofPass.createEvent(
            "", "A blockchain Conference", block.timestamp + 1 days, block.timestamp + 2 days, "New York", "open"
        );
    }

    function testCannotCreateEventWithEmptyDescription() public {
        vm.expectRevert("Event description cannot be empty.");

        proofPass.createEvent(
            "web3 conference", "", block.timestamp + 1 days, block.timestamp + 2 days, "New York", "open"
        );
    }

    function testCreateEventWithDifferentStatus() public {
        proofPass.createEvent(
            "Web3 Workshop",
            "A Solidity workshop",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Abuja",
            "upcoming"
        );

        (,,,,,, string memory status) = proofPass.events(0);

        assertEq(status, "upcoming");
    }

    function testEventCreatedEvent() public {
        vm.expectEmit(true, true, false, true);

        emit ProofPass.EventCreated(0, "Web3 Conference");

        proofPass.createEvent(
            "Web3 Conference",
            "A blockchain conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Abuja",
            "open"
        );
    }

    function testCannotCreateEventWithEmptyStatus() public {
        vm.expectRevert("Event status cannot be empty.");

        proofPass.createEvent(
            "Web3 Conference",
            "A blockchain conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Abuja",
            ""
        );
    }

    function testCannotUpdateEventWithEmptyStatus() public {
        proofPass.createEvent(
            "Web3 Conference",
            "A blockchain conference",
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Abuja",
            "open"
        );

        vm.expectRevert("Event status cannot be empty.");

        proofPass.updateEventStatus(0, "");
    }

    function testOrganizerIsDeployer() public {
        assertEq(proofPass.organizer(), address(this));
    }

    function testContractDoesNotAcceptEther() public {
        EtherSender sender = new EtherSender();

        vm.deal(address(sender), 1 ether);

        vm.expectRevert("ETH transfer failed.");

        sender.sendEther{value: 1 ether}(payable(address(proofPass)));
    }
}

contract EtherSender {
    function sendEther(address payable recipient) external payable {
        (bool success,) = recipient.call{value: msg.value}("");
        require(success, "ETH transfer failed.");
    }
}
