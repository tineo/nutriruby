require 'mongoid'
require "google_drive"
require './reading'

Mongoid.load!('mongoid.yml', :production)

class SenderReading
    
    def initialize(ha:1,ht:2,tm:3,lm:4,ps:5,unix_time:0,file_name:'')
        @ha=ha
        @ht=ht
        @tm=tm
        @lm=lm
        @ps=ps
        @unix_time = unix_time
        @file_name = file_name
    end
    
    def sendDrive(file_name:'')
        file_name = file_name;
        puts "filename: #{file_name}"
        pwd = Dir.pwd

        session = GoogleDrive::Session.from_config("sistemaespinaca-7d522b23ba38.json")

        folder_id = '1y2jfR6_wanP3_Hyn7kp1ZWE00pxIJAsb'

        upfile = session.collection_by_url("https://drive.google.com/#folders/#{folder_id}").upload_from_file("#{pwd}/photos/#{file_name}", "#{file_name}", convert:false)

        linko =  "https://drive.google.com/uc?export=view&id=#{upfile.id}"
        linko
    end

    def sendmlab (link:'')
        Lectura.delete_all
        dato = Lectura.new(
        ha: @ha,
        ht: @ht,
        tm: @tm,
        lm: @lm,
        ps: @ps,
        unix: @unix_time,
        purl: link
        )

        dato.save!

        data = Lectura.where(ha:'1').sort(ha: 1)

        data.each{ |doc| puts "ggrino #{doc['unix']}" }
    end

end

