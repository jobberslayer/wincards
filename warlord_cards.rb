require 'rubygems'
require 'RMagick'
require 'rvg/rvg'

include Magick

# allows us to use .in on measurement
RVG::dpi = 100

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

def card(image)
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

  card_img = Image.read(image).first
  card_img.resize!(2.5.in, 3.5.in) 
  @canvas.composite!(card_img, @x.in, @y.in, OverCompositeOp)

  # advance x coord for start of next card
  @x = @x + @card_width + @filler_x 
end

def print_sheet()
  sheet_name = @card_sheet_basename + '_' + '%02d' % @sheet_count + '.' + @card_sheet_extension
  puts "Printing Sheet #{sheet_name}"
  #@gc.draw(@canvas)
  @canvas.write(sheet_name)
  new_canvas()
end

def new_canvas()
  @canvas = Magick::Image.new(@width.in, @height.in)
  #, Magick::HatchFill.new('white','lightcyan2'))
end

new_canvas()

if ARGV[0].nil?
  puts "Must provide a card dat file as argument."
  exit
end

begin
  File.open(ARGV[0]) do |file|
    while card_img = file.gets
      card_img.chomp!
      puts "adding [#{card_img}]"
      card("cards/#{card_img}")
    end
  end
rescue => e
  puts e.message
  exit
end

print_sheet()

puts "!!!DONE!!!"
