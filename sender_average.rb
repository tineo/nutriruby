require 'mongoid'
require "google_drive"
require './average'
Mongoid.load!('mongoid.yml', :production)
Mongoid.raise_not_found_error = true


class SenderAverage
    
    def initialize(ha:1,ht:2,tm:3,lm:4,ps:5,unix_time:0)
        @ha=ha
        @ht=ht
        @tm=tm
        @lm=lm
        @ps=ps
        @unix_time = unix_time
        @today = Date.today.to_time.to_i
    end
    
    def getDaily
        puts "Average.count #{Average.count}"
        if Average.count > 0
            @data = Average.find_by(unix: @today)
            puts @data.ha
            puts @data.nlecturas
        else
            puts Average.count
        end
    end

    def sendmlab
        
        if @data.nil?
            dato = Average.new(
            ha: @ha,
            ht: @ht,
            tm: @tm,
            lm: @lm,
            ps: @ps,
            unix: @today,
            nlecturas: 1
            )

            dato.save!

        else
            nnlecturas = @data.nlecturas + 1
            nha = (@data.ha * @data.nlecturas + @ha ) *1.0 / nnlecturas
            nht = (@data.ht * @data.nlecturas + @ht ) *1.0 / nnlecturas
            ntm = (@data.tm * @data.nlecturas + @tm ) *1.0 / nnlecturas
            nlm = (@data.lm * @data.nlecturas + @lm ) *1.0 / nnlecturas
            nps = (@data.ps * @data.nlecturas + @ps ) *1.0 / nnlecturas
            
            Average.where(unix: @today).update({
                ha: nha,
                ht: nht,
                tm: ntm,
                lm: nlm,
                ps: nps,
                unix: @today,
                nlecturas: @data.nlecturas+1
            })
        end
    end
end

