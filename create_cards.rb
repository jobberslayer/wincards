require 'rubygems'
require 'RMagick'
require 'rvg/rvg'

include Magick

# allows us to use .in on measurement
RVG::dpi = 72

@width  = 8.5
@height = 11

@card_width  = 2.5
@card_height = 3.5 

@filler_x = 0.25
@filler_y = 0.15

@card_sheet_basename = 'card_sheet'
@card_sheet_extension = 'png'
@sheet_count = 1

@x = 0 + @filler_x 
@y = 0 + @filler_y

def card()
  if (@x + @card_width > @width)
    # Go to next line
    @x = 0 + @filler_x 
    @y = @y + @card_height + @filler_y

    # Go to next sheet
    if (@y > @height)
      @y = 0 + @filler_y
      print_sheet()
      @sheet_count += 1
    end
  end

  puts "#{@x} #{@y} #{@x + @card_width} #{@y + @card_height}"
  @gc.rectangle(@x.in, @y.in, (@x + @card_width).in, (@y + @card_height).in)
  damage('H', 0)
  execute(10)
  stun(0)
  momentum(0)
  @text_y = @y + 0.2 
  @current_line = 1
  # name
  line('Straight Punch')
  # move type
  line('Punch')

  line(' ')

  #Your Position
  line("Standing");
  #Opponent Position
  line("Opp: Standing + 0")

  line(' ')

  # Special Properties
  line("Success gives +3 bonus")
  line("to next move effects")
  line("if same body part.")

  # advance x coord for start of next card
  @x = @x + @card_width + @filler_x 
end

def text_start
  @gc.stroke('transparent')
  @gc.fill('black')
  @gc.font_family = 'monaco'
end

def text_end
  @gc.fill_opacity(0)
  @gc.stroke('black')
end

def line(n)
  text_start
  @gc.text_align(CenterAlign)
  @gc.text((@x + @card_width/2).in, (@text_y + @current_line * 0.2).in, n)
  @gc.text_align(LeftAlign)
  @current_line += 1
  text_end
end

# Top Right
def execute(n)
  text_start
  @gc.text((@x + @card_width - 0.4).in, (@y + 0.2).in, "X%2d" % n.to_s) 
  text_end
end

# Bottom Right
def momentum(n)
  text_start
  @gc.text((@x + @card_width - 0.4).in, (@y + @card_height - 0.1).in, "M%2d" % n.to_s) 
  text_end
end

# Top Left
def damage(body, n)
  text_start
  @gc.text((@x + 0.1).in, (@y + 0.2).in, "#{body}%2d" % n.to_s) 
  text_end
end

# Bottom Left
def stun(n)
  text_start
  @gc.text((@x + 0.1).in, (@y + @card_height - 0.1).in, "S%2d" % n.to_s) 
  text_end
end


def print_sheet()
  sheet_name = @card_sheet_basename + '_' + '%02d' % @sheet_count + '.' + @card_sheet_extension
  puts "Printing Sheet #{sheet_name}"
  @gc.draw(@canvas)
  @canvas.write(sheet_name)
  new_canvas()
end

def new_canvas()
  @canvas = Magick::Image.new(@width.in, @height.in)
  #, Magick::HatchFill.new('white','lightcyan2'))
  @gc = Magick::Draw.new()
  @gc.stroke('black')
  @gc.stroke_width(3)
  @gc.fill_opacity(0)
end

new_canvas()

card()
card()
card()

card()
card()
card()

card()
card()
card()

card()
card()
card()

print_sheet()

puts "!!!DONE!!!"
exit
# Draw ellipse
gc.stroke('red')
gc.stroke_width(3)
gc.fill_opacity(0)
gc.ellipse(120, 150, 80, 120, 0, 270)

# Draw endpoints
gc.stroke('gray50')
gc.stroke_width(1)
gc.circle(120, 150, 124, 150)
gc.circle(200, 150, 204, 150)
gc.circle(120,  30, 124,  30)

# Draw lines
gc.line(120, 150, 200, 150)
gc.line(120, 150, 120,  30)

# Annotate
gc.stroke('transparent')
gc.fill('blue')
gc.text(130, 35, "End")
gc.text(188, 135, "Start")
gc.text(130, 95, "'Height=120'")
gc.text(55, 155, "'Width=80'")

gc.text(5.in, 11.3.in, "BOTTOM") 
gc.line(0.in, 11.4.in, 8.5.in, 11.4.in)

gc.draw(canvas)
canvas.write('shapes.gif')

puts "!!!DONE!!!"
