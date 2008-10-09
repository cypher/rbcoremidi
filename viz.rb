# HACKALICIOUS PROOF OF CONCEPT
# Look! The square pulses to the kick drum!
# If you use this code in anything I will face punch you, it's horrible and fit for nothing more than demonstrating this is possible
# Make sure you install the ruby-opengl gem using system gem, not ports gem

require 'rubygems'
require 'coremidi'
require 'opengl'
# Start archaeopteryx 
# Start GarageBand (just to make sure it's all working)

# Open MIDI Patch Bay.app
# Create a new input (anyname)
# Create a new output (anyname)
# GarageBand will announce that it has found a new input
# You should have sound, yay

# Now run this script


class ExampleMidiConsumer
  include CoreMIDI

  def initialize
    puts CoreMIDI.sources

    # Names are arbitrary
    client = CoreMIDI.create_client("SB")
    port = CoreMIDI.create_input_port(client, "PortA")
    connect_source_to_port(0, port) # 0 is index into CoreMIDI.sources array
    @kick = false
  end

  def capture
    while true
     if data = new_data?
       puts data.inspect
     end
   end
  end

  def data
    d = new_data?
    return unless d
    if d.first.data.first == 146
      @kick = true
    else
      @kick = false
    end
    d || []
  end
  attr_accessor :kick
end
c = ExampleMidiConsumer.new
def myinit
    mat_ambient = [ 0.0, 0.0, 0.0, 1.0 ];
#/*   mat_specular and mat_shininess are NOT default values	*/
    mat_diffuse = [ 0.4, 0.4, 0.4, 1.0 ];
    mat_specular = [ 1.0, 1.0, 1.0, 1.0 ];
    mat_shininess = [ 15.0 ];

    light_ambient = [ 0.0, 0.0, 0.0, 1.0 ];
    light_diffuse = [ 1.0, 1.0, 1.0, 1.0 ];
    light_specular = [ 1.0, 1.0, 1.0, 1.0 ];
    lmodel_ambient = [ 0.2, 0.2, 0.2, 1.0 ];

    Gl.glMaterial(Gl::GL_FRONT, Gl::GL_AMBIENT, mat_ambient);
    Gl.glMaterial(Gl::GL_FRONT, Gl::GL_DIFFUSE, mat_diffuse);
    Gl.glMaterial(Gl::GL_FRONT, Gl::GL_SPECULAR, mat_specular);
    Gl.glMaterial(Gl::GL_FRONT, Gl::GL_SHININESS, *mat_shininess);
    Gl.glLight(Gl::GL_LIGHT0, Gl::GL_AMBIENT, light_ambient);
    Gl.glLight(Gl::GL_LIGHT0, Gl::GL_DIFFUSE, light_diffuse);
    Gl.glLight(Gl::GL_LIGHT0, Gl::GL_SPECULAR, light_specular);
    Gl.glLightModel(Gl::GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);

    Gl.glEnable(Gl::GL_LIGHTING);
    Gl.glEnable(Gl::GL_LIGHT0);
    Gl.glDepthFunc(Gl::GL_LESS);
    Gl.glShadeModel(GL_SMOOTH) # Select Smooth Shading
    Gl.glEnable(Gl::GL_DEPTH_TEST);
end
def drawPlane
    Gl.glBegin(Gl::GL_QUADS);
    Gl.glNormal(0.0, 0.0, 1.0);
    Gl.glVertex(-1.0, -1.0, 0.0);
    Gl.glVertex(0.0, -1.0, 0.0);
    Gl.glVertex(0.0, 0.0, 0.0);
    Gl.glVertex(-1.0, 0.0, 0.0);

    Gl.glNormal(0.0, 0.0, 1.0);
    Gl.glVertex(0.0, -1.0, 0.0);
    Gl.glVertex(1.0, -1.0, 0.0);
    Gl.glVertex(1.0, 0.0, 0.0);
    Gl.glVertex(0.0, 0.0, 0.0);

    Gl.glNormal(0.0, 0.0, 1.0);
    Gl.glVertex(0.0, 0.0, 0.0);
    Gl.glVertex(1.0, 0.0, 0.0);
    Gl.glVertex(1.0, 1.0, 0.0);
    Gl.glVertex(0.0, 1.0, 0.0);

    Gl.glNormal(0.0, 0.0, 1.0);
    Gl.glVertex(0.0, 0.0, 0.0);
    Gl.glVertex(0.0, 1.0, 0.0);
    Gl.glVertex(-1.0, 1.0, 0.0);
    Gl.glVertex(-1.0, 0.0, 0.0);
    Gl.glEnd();
end
display = Proc.new {
    infinite_light = [ 1.0, 1.0, 1.0, 0.0 ];
    local_light = [ 1.0, 1.0, 1.0, 1.0 ];

    Gl.glClear(Gl::GL_COLOR_BUFFER_BIT | Gl::GL_DEPTH_BUFFER_BIT);

    if c.kick
      Gl.glPushMatrix();
      Gl.glTranslate(0.0, 0.0, 0.0);
      Gl.glLight(Gl::GL_LIGHT0, Gl::GL_POSITION, infinite_light);
        drawPlane();
      Gl.glPopMatrix();
    end
    Gl.glFlush();
    Glut.glutSwapBuffers()
}
myReshape = Proc.new {|w, h|
    Gl.glViewport(0, 0, w, h);
    Gl.glMatrixMode(Gl::GL_PROJECTION);
    Gl.glLoadIdentity();
    if (w <= h) 
	Gl.glOrtho(-1.5, 1.5, -1.5*h/w, 1.5*h/w, -10.0, 10.0);
    else 
	Gl.glOrtho(-1.5*w/h, 1.5*w/h, -1.5, 1.5, -10.0, 10.0);
    end
    Gl.glMatrixMode(Gl::GL_MODELVIEW);
}
idle = lambda do
  c.data
	glutPostRedisplay()
end
    Glut.glutInit
    Glut.glutInitDisplayMode(Glut::GLUT_SINGLE | Glut::GLUT_RGB | Glut::GLUT_DEPTH);
    Glut.glutInitWindowSize(800, 600);
    Glut.glutCreateWindow($0);
    myinit();
    Glut.glutReshapeFunc(myReshape);
    Glut.glutDisplayFunc(display);
    Glut.glutIdleFunc(idle);
  #  Glut.glutKeyboardFunc(keyboard);
    Glut.glutMainLoop();
