require 'rubygems'
require 'RMagick'
require 'rvg/rvg'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'net/http'

include Magick

# allows us to use .in on measurement
@img_files = [] 
RVG::dpi = 100

@width  = 8.5
@height = 11

@card_width  = 2.5
@card_height = 3.5 

@filler_x = 0.25
@filler_y = 0.15

@card_sheet_basename = 'card_sheet'
#@card_sheet_extension = 'png'
@card_sheet_extension = 'pdf'
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
  @img_files << sheet_name
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

#FileUtils.rm Dir.glob '*.png'
FileUtils.rm Dir.glob '*.pdf'


popup_url = 'http://www.temple-of-lore.com/spoiler/popup.php?name={0}'
image_base_url = 'http://www.temple-of-lore.com/{0}'
begin
  File.open(ARGV[0]) do |file|
    while card_img = file.gets
      card_img.strip!.chomp! if card_img
      next if card_img.start_with?('#') 
      if (card_img =~ /(^\d) (.*)/)
        num_of = $1
        card_img = $2
      else
        num_of = 1  
      end

      unless File.exists?("cards/#{card_img}.jpg")
        card_img_encode = URI::encode(card_img)
        doc = Nokogiri::HTML(open("http://www.temple-of-lore.com/spoiler/popup.php?name=#{card_img_encode}"))
        img_url = doc.search('//img/@src').text
        print "http://www.temple-of-lore.com/spoiler/#{img_url}"
        #open("http://www.temple-of-lore.com/spoiler/#{img_url}") {|f|
        #  File.open("cards/#{card_img}.jpg","wb") do |file|
        #    file.puts f.read
        #  end
        #}
        Net::HTTP.start('www.temple-of-lore.com') { |http|
          resp = http.get("/spoiler/#{img_url}")
          open("cards/#{card_img}.jpg", 'wb') { |img_file|
            img_file.write(resp.body)
          }
        }
      end

      for x in 1..num_of.to_i
        puts "adding [#{card_img}]"
        card("cards/#{card_img}.jpg")
      end
    end
  end
rescue => e
  puts "RESCUED"
  puts e.message
  puts e.backtrace
  exit
end

print_sheet()

file_list = @img_files.join(" ");
system "convert #{file_list} final.pdf"
@img_files.each do |file|
  File.delete(file)
end
puts "!!!DONE!!!"
