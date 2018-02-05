String[] lines, labels;
float[] values;
float[] position, barHeight, offSet;
float interval;
float max = -9999999, min = 0, range = 0, midpoint;
boolean line = false, lineComplete = false, barComplete = true;
float[] connectXEnd, connectYEnd;
float barWidth, round = 0;
int maxLabelLength = 0;
int widthNow = 0, heightNow = 0;
String xLabel, yLabel;

void setup() { 
  size(1500, 1000);
  widthNow = width;
  heightNow = height;
  background(200);
  surface.setResizable(true);
  lines = loadStrings("557thing.csv"); 
  labels = new String[lines.length-1];
  values = new float[lines.length-1];
  position = new float[lines.length-1];
  barHeight = new float[lines.length-1];
  connectXEnd = new float[lines.length-1];
  connectYEnd = new float[lines.length-1];
  offSet = new float[lines.length-1];
  interval = 0;
  
  String[] labelNames = splitTokens(lines[0], ",");
  xLabel = (labelNames[0]);
  yLabel = (labelNames[1]);
  
  for(int i = 1; i < lines.length; i++) { 
        String[] tokens = splitTokens(lines[i], ","); 
        String x = tokens[0]; 
        float abc = Float.parseFloat(tokens[1]); 
        labels[i-1] = x;
        if (labels[i-1].length() > maxLabelLength) {
           maxLabelLength = labels[i-1].length(); 
        }
        values[i-1] = abc;
        if (abc > max) {
           max = abc; 
        }
        if (abc < min) {
           min = abc; 
        }
        interval = (width-200) / (labels.length);
        position[i-1] = 100.0 + interval * (i-1);
        if (values[i-1] > 0) {
          offSet[i-1] = 5;
        }
        else {
          offSet[i-1] = -5; 
        }
  }
  
  range = (height-200)/(max - min);
  midpoint = 100+max/(max-min)*(height-200);
  barWidth = interval/2.0;
  
  for(int i = 1; i < lines.length; i++) { 
    barHeight[i-1] = range*(values[i-1]); 
  }
  for(int i = 0; i < lines.length-1; i++) { 
     connectXEnd[i] = position[i]+interval/2;
     connectYEnd[i] = positionFromValue(values[i]+offSet[i]);
  }
}

float positionFromValue(float value) {
  return height-100-(value-min)*range;
}

void draw() {
  
  if (widthNow != width) {
    interval = (width-200) / (labels.length);
    if (!line) {
      barWidth = interval/2.0;
    }
  }
  if (heightNow != height) {
    range = (height-200)/(max - min);
    midpoint = 100+max/(max-min)*(height-200);
    for(int i = 1; i < lines.length; i++) { 
      barHeight[i-1] = range*(values[i-1]); 
    }
  }
  widthNow = width;
  heightNow = height;
  background(200);
  textSize(30);
  
  //labels
  
  textAlign(CENTER, TOP);              
  text(xLabel, width/2, height-60);
  pushMatrix();
  translate(width/2, height/2);
  rotate(PI/2);
  text(yLabel, 0 ,width/2-40);
  popMatrix();
  
  // Make sure it is in bar form
  
  if(!line) {
    if (barWidth < interval/2) {
      barWidth = lerp(barWidth,interval/2+0.3,0.1);
    }
    if (round > 0) {
      round = lerp(round, -1, 0.1);
    }
    else {
      barComplete = true; 
    }
  }
  
  // turn into dots
  
  else {
    if (barWidth > 10) {
      barWidth = lerp(barWidth,9.7,0.1);
    }
  }
  
   rectMode(CORNER);  
   fill(255,255,0);
   rect(width-120,30,70,30);
   fill(0);
   textSize(16);
   textAlign(CENTER, CENTER);
   if (line) {
     text("bar", width-85, 45);
   }
   else {
     text("line", width-85, 45);
   }

   line(100,height-100,100,100);
   line(100,midpoint,width-50,midpoint);
   textSize(20);
   textAlign(RIGHT, CENTER);   
   int intervalOfMarks = (int) Math.pow(10, Math.round(Math.log10(max-min))-1);

   for (float i = Math.round(min/10)*10; i < max; i = i + intervalOfMarks) {
      fill(0);
      text(str(i), 90, positionFromValue(i));
      fill(210,210,210);
      line(100,positionFromValue(i),width-50,positionFromValue(i));
   }
   
   fill(255, 0, 0);
   textSize(8);
   textAlign(CENTER, CENTER);
   
   for(int i = 0; i < lines.length-1; i++) {  
     position[i] = 100.0 + interval * (i);
     if (line) {
       if (Math.abs(barHeight[i]) > 10) {
         barHeight[i] = lerp(barHeight[i],9.7,.1); 
         lineComplete = false;
       }
     }
     if (line && Math.abs(barHeight[i]) > 10) {
       barHeight[i] = lerp(barHeight[i],9.7,.1); 
       lineComplete = false;
     }
     if (!line) {
       if (barHeight[i] < Math.abs(range*values[i]+0.1)) {
         barHeight[i] = lerp(barHeight[i],range*values[i],0.1); 
       }
     }
   }
   
   for(int i = 0; i < lines.length-1; i++) { 
     lineComplete = true && (barHeight[i] <= 10) && line;
   }
   
   if ((line && lineComplete)) {
     for(int i = 0; i < lines.length-2; i++) { 
       if (Math.abs(connectXEnd[i] - position[i+1]+interval/2) > 0.1 || Math.abs(connectYEnd[i] - positionFromValue(values[i+1])+offSet[i+1]) > 0.1) {
         connectXEnd[i] = lerp(connectXEnd[i], position[i+1]+interval/2, 0.3);
         connectYEnd[i] = lerp(connectYEnd[i], positionFromValue(values[i+1])+offSet[i+1], 0.3);
       }
       if (round < 31) {
         round = lerp(round, 30, 0.0002); 
       }
       line(position[i]+interval/2, positionFromValue(values[i])+offSet[i], connectXEnd[i], connectYEnd[i]);
     }
   }
   
   if(!line) {
     for(int i = 0; i < lines.length-1; i++) { 
       if (connectXEnd[i] > position[i]+interval/2+0.1) {
         connectXEnd[i] = lerp(connectXEnd[i], position[i]+interval/2-0.1, 0.3);
         connectYEnd[i] = lerp(connectYEnd[i], positionFromValue(values[i])+offSet[i], 0.3);
         line(position[i]+interval/2, positionFromValue(values[i]), connectXEnd[i], connectYEnd[i]);
       }
       else {
         connectXEnd[i] = position[i]+interval/2;
       }      
     }
   }
   
   for(int i = 0; i < lines.length-1; i++) { 
       fill(255, 0, 0);
       rect(position[i]+interval/2.0-barWidth/2.0, positionFromValue(values[i]), barWidth, barHeight[i], round);
       fill(0);
       textAlign(CENTER);
       textSize(width/(lines.length-1)/8);
       if (values[i] > 0) {
         textAlign(CENTER, TOP);
         text(labels[i], position[i], midpoint, interval, 200);
       }
       else {
         textAlign(CENTER, TOP);
         text(labels[i], position[i], midpoint - 30, interval, 200);
       }
   }
   
   for(int i = 0; i < lines.length-1; i++) {
    if((mouseX > (position[i]+interval/2 - barWidth/2)) && (mouseX < (position[i]+interval/2 + barWidth/2)) 
    && ((mouseY < (positionFromValue(values[i]) + barHeight[i])) && (mouseY > (positionFromValue(values[i]) - 3))
    || (mouseY > (positionFromValue(values[i]) + barHeight[i])) && (mouseY < (positionFromValue(values[i]) - 3)))) {
      fill(255);
      rect(mouseX - 110, mouseY-110, 110, 110);
      fill(0);
      textSize(16);
      textAlign(CENTER, CENTER);
      text("(" + labels[i] + ", " + values[i] + ")", mouseX-105, mouseY-105, 100, 100);
    }
  }
}

// Convert between charts

void mousePressed() {
  if (mouseX > width-120 && mouseX < width-50 &&
      mouseY > 30 && mouseY < 60) {
    line = !line;
    if (line) {
      barComplete = false; 
    }
    if (!line) {
       lineComplete = !lineComplete; 
    }
    //println(line);
  }
}