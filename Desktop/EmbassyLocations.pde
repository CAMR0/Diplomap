import java.util.Collections;
PImage worldMap;
int currentYear;
HScrollBar yearScroll;
ArrayList<DiploRelation> relations;
ArrayList<Country> countries;

void setup(){
  fullScreen();
  //size(800,1200);
  loadData();
  worldMap = loadImage("/worldMap2.png");
  image(worldMap,0,height/6,width,width);
  yearScroll = new HScrollBar(width/8,height*7/8,width*3/4,height/24,1);
}


void draw(){
  clear();
  image(worldMap,0,height/6,width,width);
  yearScroll.update();
  yearScroll.display();
  changeYear((int)(1800+(yearScroll.getPos()-(width/8))/(width*3/4)*200));
  textSize(height/12);
  stroke(255);
  text(currentYear+"",width/4,height/12);
  mapPoint(getCountry(200).getLatitude(),getCountry(200).getLongitude());
  ArrayList<DiploRelation> DR = getRelationsOfYear(currentYear);
  if (DR.size()>0){
    mapRelations(DR);
  } else {
    currentYear++;
  }
  println(DR.size());
  textSize(height/64);
  fill(255,0,0);
  ellipse(width/12,height/8,width/32,width/32);
  text("chargé d'affaires",width/18,height/10);
  fill(0,255,0);
  ellipse(width/4,height/8,width/32,width/32);
  text("minister",width/4,height/10);
  fill(0,0,255);
  ellipse(width/2,height/8,width/32,width/32);
  text("ambassador",width/2,height/10);
  fill(127,127,127);
  ellipse(width*3/4,height/8,width/32,width/32);
  text("other",width*3/4,height/10);
}

void changeYear(int Y){
  currentYear = Y;
  *?
  while (getRelationsOfYear(Y).size()==0){
    currentYear++;
    if (currentYear>2005){
      currentYear = 1817;
    }
  }
  */
}

void mapRelations(ArrayList<DiploRelation> DR){
  for (DiploRelation D : DR){
    int type = D.getDiplo1();
    /*
    switch (type){
      case 0:
        break;
      case 1:
        stroke(255,0,0);
      case 2:
        stroke(0,255,0);
      case 3:
        stroke(0,0,255);
      case 9:
        stroke(127,127,127);
    }
    */
    if (type!=0){
      if (type==1){
        stroke(255,0,0);
      } else if (type==2){
        stroke(0,255,0);
      } else if (type==3){
        stroke(0,0,255);
      } else {
        stroke(127,127,127);
      }
      mapLine(getCountry(D.getCountry1()).getLatitude(),getCountry(D.getCountry1()).getLongitude(),getCountry(D.getCountry2()).getLatitude(),getCountry(D.getCountry2()).getLongitude());
    }
  }
}

void mapPoint(double LA, double LO){
  int X = (int)(width/2+(width/2*LO/180.0));
  int Y = (int)(height/6+width/2-(width/2*LA/90.0));
  fill(color(255,0,0));
  ellipse(X,Y,20,20);
}

void mapLine(double LA1, double LO1, double LA2, double LO2){
  strokeWeight(1);
  int X1 = (int)(width/2+(width/2*LO1/180.0));
  int Y1 = (int)(height/6+width/2-(width/2*LA1/90.0));
  int X2 = (int)(width/2+(width/2*LO2/180.0));
  int Y2 = (int)(height/6+width/2-(width/2*LA2/90.0));
  line(X1,Y1,X2,Y2);
}

class HScrollBar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollBar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}

class DiploRelation {
  int country1, country2;
  int diplo1, diplo2;
  int year;
  DiploRelation(int Y, int C1, int C2, int D1, int D2){
    year = Y;
    country1 = C1;
    country2 = C2;
    diplo1 = D1;
    diplo2 = D2;
  }
  int getCountry1(){
    return country1;
  }
  int getCountry2(){
    return country2;
  }
  int getDiplo1(){
    return diplo1;
  }
  int getDiplo2(){
    return diplo2;
  }
  int getYear(){
    return year;
  }
  String toString(){
    return "In "+year+", "+getCountry(country1)+" had "+convertDiploCode(diplo1)+" sent to "+getCountry(country2)+".";
  }
}

void loadData(){
  String[] data = loadStrings("data.csv");
  relations = new ArrayList<DiploRelation>();
  for (String S : data){
    String[] numbers = S.split(",");
    relations.add(new DiploRelation(Integer.parseInt(numbers[2]),Integer.parseInt(numbers[0]),Integer.parseInt(numbers[1]),Integer.parseInt(numbers[3]),Integer.parseInt(numbers[4])));
  }
  String[] data2 = loadStrings("CC.csv");
  countries = new ArrayList<Country>();
  for (String S : data2){
    String[] info = S.split(",");
    countries.add(new Country(Integer.parseInt(info[0]),info[1],info[2],info[3],Double.parseDouble(info[4]),Double.parseDouble(info[5])));
  }
}

void printRelations(ArrayList<DiploRelation> DR){
  for (DiploRelation D : DR){
    println(D);
  }
}

ArrayList<DiploRelation> getRelationsOfCountry(int CC){
  ArrayList<DiploRelation> results = new ArrayList<DiploRelation>();
  for (DiploRelation D : relations){
    if (D.getCountry1()==CC){
      results.add(D);
    }
  }
  return results;
}

String convertDiploCode(int code){
  switch (code){
    case 0:
      return "no exchange";
    case 1:
      return "chargé d'affaires";
    case 2:
      return "minister";
    case 3:
      return "ambassador";
    case 9:
      return "other";
  }
  return "other";
}

class Country {
  int cc;
  String ab, name, capital;
  double latitude, longitude;
  Country(int C, String A, String N, String CA, double LA, double LO){
    cc = C;
    ab = A;
    name = N;
    capital = CA;
    latitude = LA;
    longitude = LO;
  }
  int getCountryCode(){
    return cc;
  }
  String getAbbreviation(){
    return ab;
  }
  String getName(){
    return name;
  }
  String getCapital(){
    return capital;
  }
  double getLatitude(){
    return latitude;
  }
  double getLongitude(){
    return longitude;
  }
  String toString(){
    return name;
  }
}

Country getCountry(int CC){
  for (Country C : countries){
    if (C.getCountryCode()==CC){
      return C;
    }
  }
  return null;
}

ArrayList<DiploRelation> getRelationsOfYear(int year){
  ArrayList<DiploRelation> results = new ArrayList<DiploRelation>();
  for (DiploRelation D : relations){
    if (D.getYear()==year){
      results.add(D);
    }
  }
  return results;
}

//String getRelation(){
  