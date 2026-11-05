/*
 TITAN ARM — preliminary six-servo mechanical layout
 Units: millimetres
 Open with OpenSCAD. Press F5 to preview, F6 to render.

 IMPORTANT:
 This is a PARAMETRIC CONCEPT MODEL, not a manufacturing-ready replica
 of the Robocraze bracket kit. The seller's exact hole pattern, plate
 thicknesses, bearing sizes and servo dimensions were not supplied.
 Verify all dimensions against the purchased frame before fabrication.
*/

$fn = 48;

// ---------- Main adjustable dimensions ----------
base_plate_x = 120;
base_plate_y = 120;
base_plate_t = 6;
base_turntable_d = 90;

shoulder_height = 95;
upper_arm_len = 145;
forearm_len = 130;
wrist_tilt_len = 42;
wrist_roll_len = 35;
gripper_len = 72;

link_width = 42;
link_depth = 18;
plate_t = 4;

// Servo placeholder dimensions (visual envelopes only)
standard_servo_x = 40;
standard_servo_y = 20;
standard_servo_z = 42;
micro_servo_x = 23;
micro_servo_y = 12;
micro_servo_z = 29;

// Joint angles for preview; change to pose the arm
base_angle = 0;
shoulder_angle = -25;
elbow_angle = 45;
wrist_tilt_angle = -20;
wrist_roll_angle = 0;
gripper_opening = 24;

// ---------- Reusable parts ----------
module rounded_plate(x,y,t,r=6) {
    linear_extrude(height=t)
        offset(r=r)
            square([x-2*r,y-2*r], center=true);
}

module servo_block(x=standard_servo_x,y=standard_servo_y,z=standard_servo_z) {
    color([0.18,0.19,0.21])
        translate([-x/2,-y/2,-z/2]) cube([x,y,z]);
    color("silver")
        translate([0,0,z/2+2]) cylinder(h=4,d=18,center=true);
}

module hinge_disc(d=48,t=8) {
    color([0.72,0.74,0.77])
        rotate([90,0,0]) cylinder(h=t,d=d,center=true);
    color([0.25,0.26,0.28])
        rotate([90,0,0]) cylinder(h=t+1,d=12,center=true);
}

module link_beam(len=100,w=link_width,d=link_depth) {
    color([0.72,0.74,0.77])
        translate([0,-w/2,-d/2])
            cube([len,w,d]);
    // visual side rails
    color([0.35,0.37,0.40]) {
        translate([0,-w/2-2,-d/2-2]) cube([len,w+4,3]);
        translate([0,-w/2-2,d/2-1]) cube([len,w+4,3]);
    }
}

module bolt_heads(xspan=70,yspan=70,z=0) {
    for (x=[-xspan/2,xspan/2], y=[-yspan/2,yspan/2])
        color([0.22,0.23,0.25])
            translate([x,y,z]) cylinder(h=2,d=6);
}

module gripper_finger(len=58, spread=24) {
    color([0.72,0.74,0.77])
        translate([0,0,0]) cube([len,10,7]);
    color([0.35,0.37,0.40])
        translate([len-12,0,-5]) cube([12,10,17]);
}

// ---------- Assembly ----------
module base_assembly() {
    color([0.12,0.13,0.15])
        translate([0,0,0]) rounded_plate(base_plate_x,base_plate_y,base_plate_t);
    bolt_heads(base_plate_x-20,base_plate_y-20,base_plate_t);
    color([0.75,0.77,0.80])
        translate([0,0,base_plate_t]) cylinder(h=8,d=base_turntable_d);
    color([0.18,0.19,0.21])
        translate([0,0,base_plate_t+8]) cylinder(h=12,d=62);
    // Servo 1: base rotation
    translate([0,0,base_plate_t+12]) servo_block();
}

module shoulder_yoke() {
    // twin side plates
    color([0.68,0.70,0.73]) {
        translate([-22,-29,0]) cube([plate_t,58,shoulder_height]);
        translate([17,-29,0]) cube([plate_t,58,shoulder_height]);
        translate([-22,-29,shoulder_height-plate_t])
            cube([44,58,plate_t]);
    }
    // Servo 2: shoulder
    translate([0,0,shoulder_height/2]) servo_block();
    translate([0,0,shoulder_height])
        hinge_disc(52,48);
}

module upper_arm() {
    // Main arm beam, pivoted at shoulder
    translate([0,0,0]) link_beam(upper_arm_len);
    // Servo 3: elbow, mounted near distal end
    translate([upper_arm_len-20,0,0]) servo_block();
    translate([upper_arm_len,0,0]) hinge_disc(46,46);
}

module forearm() {
    link_beam(forearm_len,38,16);
    // Wrist tilt servo 4
    translate([forearm_len-18,0,0]) servo_block();
    translate([forearm_len,0,0]) hinge_disc(40,42);
}

module wrist_and_gripper() {
    // Wrist tilt link
    color([0.72,0.74,0.77])
        translate([0,-18,-8]) cube([wrist_tilt_len,36,16]);
    // Servo 5: wrist roll (standard servo placeholder)
    translate([wrist_tilt_len,0,0]) servo_block();
    // Wrist roll hub
    translate([wrist_tilt_len+14,0,0])
        rotate([0,90,0]) color([0.76,0.78,0.81]) cylinder(h=10,d=30);
    // Gripper body and Servo 6: micro servo
    translate([wrist_tilt_len+wrist_roll_len,0,0]) {
        color([0.18,0.19,0.21]) cube([28,34,18],center=true);
        translate([0,0,18]) servo_block(micro_servo_x,micro_servo_y,micro_servo_z);
        // two opposing fingers
        translate([12,gripper_opening/2,0]) gripper_finger(gripper_len);
        translate([12,-gripper_opening/2-10,0])
            mirror([0,1,0]) gripper_finger(gripper_len);
    }
}

// Pose the linked arm in the X-Z plane
module arm_pose() {
    translate([0,0,base_plate_t+20])
    rotate([0,0,base_angle]) {
        shoulder_yoke();
        translate([0,0,shoulder_height])
        rotate([0,shoulder_angle,0]) {
            upper_arm();
            translate([upper_arm_len,0,0])
            rotate([0,elbow_angle,0]) {
                forearm();
                translate([forearm_len,0,0])
                rotate([0,wrist_tilt_angle,0]) {
                    wrist_and_gripper();
                }
            }
        }
    }
}

module complete_arm() {
    base_assembly();
    arm_pose();
}

complete_arm();

// ---------- Simple dimensional reference markers ----------
color([0.1,0.45,0.85,0.35])
translate([-base_plate_x/2-10,-base_plate_y/2-10,0])
    cube([2,2,shoulder_height+upper_arm_len+forearm_len+80]);
