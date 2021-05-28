const String newYork = "New York";
const String smokedDuck = "Smoked Duck";
const String lentilSoup = "Lentil Soup";
const String baklava = "Turkish Baklava";

const Map<String, Map<String, String>> products = {
  "MAIN COURSE": {newYork: "assets/menu/steak1.png"},
  "APPETISERS": {smokedDuck: "assets/menu/ordek_fume.png"},
  "SOUP": {lentilSoup: "assets/menu/soup1.png"},
  "DESSERT": {baklava: "assets/menu/havuc.png"}
};

const Map<String, int> productPrices = {
  newYork: 25,
  smokedDuck: 20,
  lentilSoup: 8,
  baklava: 10
};

const Map<String, String> productDetails = {
  newYork:
      "A strip steak comes from the short waist of a cow. This is a piece of meat that is not used extensively by the cow, which means it is particularly tender. A boneless strip steak is called a New York strip steak. The first quality meat, which covers the section where the tenderloin meat is removed, is cooked and grilled after the aging process, served with corn prepared only for you and a salad sauced according to your taste.",
  lentilSoup:
      "Hot and delicious soup made with Turkish Red Lentils. Served with Turkish pitas, lemon and with spices.",
  baklava:
      "Layered pastry dessert made of filo pastry, filled with chopped pistachious, and sweetened with syrup. It was one of the most popular sweet pastries of Ottoman cuisine. Served with ice cream or milk cream.",
  smokedDuck:
      "Smoked duck is a signature of Szechuan cuisine. The powerful smoke and rich meat is perfectly offset by the other hot and sour ingredients used in the region. Served with fresh vegetables."
};

const Map<String, String> carouselItems = {
  "Forks & Spoons, Beyoğlu": "assets/carousel/caro1.jpg",
  "Forks & Spoons, Fatih": "assets/carousel/caro2.jpg",
  "Forks & Spoons, Üsküdar": "assets/carousel/caro3.jpg",
};

const Map<String, Map<String, dynamic>> restaurantDetails = {
  "Forks & Spoons, Beyoğlu": {
    "lat": 41.0329109,
    "lng": 28.9840904,
    "tel": "+90 212 11 00",
    "address": "Hocazade St. No:2 Beyoğlu/ISTANBUL",
    "details": "A fine dining restaurant located in Beyoğlu",
  },
  "Forks & Spoons, Fatih": {
    "lat": 41.0155957,
    "lng": 28.9827176,
    "tel": "+90 212 11 11",
    "address": "Kennedy St. No:221 Fatih/ISTANBUL",
    "details": "A fine dining restaurant located in Fatih",
  },
  "Forks & Spoons, Üsküdar": {
    "lat": 41.0217315,
    "lng": 29.0111898,
    "tel": "+90 216 22 22",
    "address": "Hafız Ali Paşa Blv. No:23 Üsküdar/ISTANBUL",
    "details": "A fine dining restaurant located in Üsküdar",
  },
};
