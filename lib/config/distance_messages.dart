import 'dart:math';

class DistanceMessages {
  static final _random = Random();

  /// Get a random message based on distance in meters
  static String getMessage(double distanceMeters) {
    final messages = _getMessagesForDistance(distanceMeters);
    return messages[_random.nextInt(messages.length)];
  }

  static List<String> _getMessagesForDistance(double distance) {
    if (distance > 100000) {
      return _tooFarMessages;
    } else if (distance > 50000) {
      return _veryFarMessages;
    } else if (distance > 10000) {
      return _farMessages;
    } else if (distance > 5000) {
      return _mediumFarMessages;
    } else if (distance > 1000) {
      return _gettingCloserMessages;
    } else if (distance > 500) {
      return _prettyCloseMessages;
    } else if (distance > 100) {
      return _veryCloseMessages;
    } else if (distance > 50) {
      return _almostThereMessages;
    } else if (distance > 10) {
      return _soCloseMessages;
    } else {
      return _youMadeItMessages;
    }
  }

  // Too far (>100km)
  static const _tooFarMessages = [
    "Kenny is waiting for you in Tromsø, Norway!",
    "Time to book a flight to the Arctic!",
    "Norway is calling... will you answer?",
    "Kenny can't even see you from here.",
    "You're so far, Kenny thinks you're a myth.",
    "Plot twist: you need to actually travel there.",
    "GPS says: 'Are you serious right now?'",
    "Kenny: 'I'll just wait here... forever, I guess.'",
    "You could walk, but I wouldn't recommend it.",
    "Kenny's getting cold waiting for you.",
  ];

  // Very far (50-100km)
  static const _veryFarMessages = [
    "Still pretty far, but at least you're trying!",
    "You're in the general vicinity of Norway, maybe?",
    "Kenny can almost sense your presence... not really.",
    "Marathon runners would be tired by now.",
    "Have you considered teleportation?",
    "A scenic drive awaits!",
    "You're getting warmer... well, geographically colder actually.",
    "Kenny: 'Is someone coming? Hello?'",
    "The journey of a thousand miles begins with... many more miles.",
    "Pack some snacks, this will take a while.",
  ];

  // Far (10-50km)
  static const _farMessages = [
    "Long way to go, but worth it!",
    "Keep moving, you'll get there eventually!",
    "Kenny's up there somewhere, waiting...",
    "Perfect distance for an adventure!",
    "Grab a coffee, you've got some ground to cover.",
    "The Arctic wind is calling your name!",
    "Kenny: 'I can wait. I'm made of plastic.'",
    "You're on the right track!",
    "Just a few more hills... and mountains... and fjords.",
    "This is what legs are for!",
    "A healthy hike never hurt anyone.",
    "Kenny's practicing his poses for your arrival.",
    "The view will be worth it!",
    "Adventure mode: ACTIVATED",
  ];

  // Medium far (5-10km)
  static const _mediumFarMessages = [
    "Getting somewhere now!",
    "Kenny's starting to get excited!",
    "Not bad! Keep it up!",
    "You could jog this in... a while.",
    "The mountain air is getting closer!",
    "Kenny: 'I think I hear footsteps!'",
    "You're making progress, champ!",
    "The statue awaits its visitor!",
    "A brisk walk... for several hours.",
    "Kenny's polishing his hood for you!",
    "You're officially 'in the area'!",
    "Local GPS: 'Getting warmer!'",
    "Kenny can almost smell your determination.",
    "The countdown has begun!",
  ];

  // Getting closer (1-5km)
  static const _gettingCloserMessages = [
    "Getting warmer...",
    "Kenny senses a disturbance in the force!",
    "You're in the neighborhood!",
    "Not far now, keep going!",
    "The final stretch approaches!",
    "Kenny: 'Mmmph mmph!' (That's excitement)",
    "You could sprint this! Don't, but you could.",
    "Almost within shouting distance!",
    "The mountain is right there!",
    "Kenny's doing a little dance!",
    "You can almost feel the 14kg of ABS plastic!",
    "This is getting real!",
    "The legend awaits!",
    "Final boss territory!",
    "Kenny's getting nervous with anticipation!",
    "Your quest is nearing completion!",
  ];

  // Pretty close (500m-1km)
  static const _prettyCloseMessages = [
    "So close! Kenny is nearby!",
    "You're practically neighbors now!",
    "Just a short walk away!",
    "Kenny: 'I can hear your phone!'",
    "The orange parka is near...",
    "You might see a glint of gold!",
    "Almost time for a selfie!",
    "Kenny's preparing his best pose!",
    "The stone ring awaits!",
    "Just over that hill... maybe.",
    "Getting that Arctic workout!",
    "Kenny's heart would be racing if he had one!",
    "The moment approaches!",
    "Check your camera battery!",
    "You're in the final stretch!",
  ];

  // Very close (100-500m)
  static const _veryCloseMessages = [
    "Look around, Kenny's close!",
    "Kenny can probably see you!",
    "Time to start looking!",
    "The orange figure awaits!",
    "You're basically there!",
    "Kenny: 'Over here!'",
    "Can you see the stones?",
    "The sacred ground is near!",
    "Photo opportunity approaching!",
    "Kenny's waving! (Not really, he's plastic)",
    "Eyes peeled for orange!",
    "The mystery reveals itself!",
    "You're writing history!",
    "The statue is within reach!",
    "Kenny's doing his best statue impression!",
    "Almost touching distance!",
  ];

  // Almost there (50-100m)
  static const _almostThereMessages = [
    "You're SO CLOSE!",
    "Kenny's right there!",
    "Just a few more steps!",
    "Can you see the orange?!",
    "THE LEGEND IS NEAR!",
    "Kenny: 'MMMPH MMPH MMPH!'",
    "Victory is imminent!",
    "Your quest is almost complete!",
    "The 14kg of glory awaits!",
    "Stone ring spotted?",
    "Kenny's doing a happy dance!",
    "Achievement nearly unlocked!",
    "The prophecy fulfills!",
    "Final approach!",
    "Prepare for awesomeness!",
  ];

  // So close (10-50m)
  static const _soCloseMessages = [
    "RIGHT THERE!",
    "KENNY IS LITERALLY RIGHT THERE!",
    "TURN AROUND!",
    "YOU CAN TOUCH HIM!",
    "THE MOMENT HAS COME!",
    "Kenny: *excited plastic noises*",
    "GOAL IN SIGHT!",
    "VICTORY DANCE TIME!",
    "THE LEGEND STANDS BEFORE YOU!",
    "14 KG OF PURE ART!",
    "TAKE THE PHOTO!",
    "BASK IN THE GLORY!",
    "YOU FOUND HIM!",
    "THE QUEST IS COMPLETE!",
    "KENNY APPROVES!",
  ];

  // You made it (<10m)
  static const _youMadeItMessages = [
    "YOU'RE BASICALLY THERE!",
    "GIVE KENNY A HUG!",
    "ACHIEVEMENT UNLOCKED: KENNY FOUND!",
    "YOU DID IT! YOU ACTUALLY DID IT!",
    "Kenny: 'Mmmph!' (Welcome!)",
    "The stone ring welcomes you!",
    "14 kg of ABS plastic glory!",
    "You found the Arctic Kenny!",
    "This is the moment!",
    "The mysterious statue reveals itself!",
    "Take ALL the photos!",
    "Kenny appreciates your dedication!",
    "Arctic legend status: ACHIEVED!",
    "You're now part of the story!",
    "Kenny's been waiting for you!",
    "The journey was worth it!",
    "Don't forget to leave a stone!",
    "Kenny: *happy muffled sounds*",
    "You made the pilgrimage!",
    "LEGENDARY!",
  ];
}
