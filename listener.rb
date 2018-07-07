require 'rubyserial'
require 'serialport'

require 'json'

require './sender_reading'
require './sender_average'
require 'pi_piper'
include PiPiper


class Listener
    def initialize
        #@arduino = Serial.new '/dev/ttyACM0'

        @pin1 = PiPiper::Pin.new(:pin => 17, :direction => :out)
        @pin2 = PiPiper::Pin.new(:pin => 18, :direction => :out)

        @port_str = "/dev/ttyACM0"
        @baud_rate = 9600
        @data_bits = 8
        @stop_bits = 1
        @parity = SerialPort::NONE
        @sp = SerialPort.new(@port_str, @baud_rate, @data_bits, @stop_bits, @parity)

        @sp.flush()
    end

    def readSerial
        @sp.flush()
        if (i = @sp.gets.chomp)
            puts i
            lectura = i
        end
        @sp.flush()
        lectura
    end

    def readCamera(unix_time)
        file_name = "img_#{unix_time}.jpg";
        pwd = Dir.pwd
        system( "fswebcam #{pwd}/photos/#{file_name}" )
        file_name
    end

    def valid_json?(json)
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
    end

    def looper
        loop do
            unix_time = Time.now.to_i
            fin = self.readCamera(unix_time)
            l = self.readSerial
            puts "lectura de arduino :#{l}"
            pwd = Dir.pwd
            
            if self.valid_json?(l)
                p ardata = JSON.parse(l, {:symbolize_names=>true})
            
                puts ardata

                if ardata[:ht] > 170
                    # mas de 170 de sequedad
                    pin1.on
                    pin2.off
                else
                    pin1.off
                    pin1.off
                end

                s = SenderReading.new(
                    :ha => ardata[:ha], 
                    :ht => ardata[:ht], 
                    :tm => ardata[:tm], 
                    :lm => ardata[:lm], 
                    :ps => ardata[:ps],
                    :unix_time => unix_time
                    )
                link = s.sendDrive(:file_name => fin)
                
                s.sendmlab(
                    :link => link)
                
                sa = SenderAverage.new(
                    :ha => ardata[:ha], 
                    :ht => ardata[:ht], 
                    :tm => ardata[:tm], 
                    :lm => ardata[:lm], 
                    :ps => ardata[:ps],
                    :unix_time => unix_time
                    )
                sa.getDaily
                sa.sendmlab
            end
            #sleep(5.minutes)
            sleep(12.seconds)
        end
    end
end

l = Listener.new
l.looper