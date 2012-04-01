# -*- coding: utf-8 -*-

require "rubygems"
require "calendar/japanese/holiday"
require "csv"
require "pp"

# Time クラスに Mix-in する
class Time
  include Calendar::Japanese::Holiday
end

class CreateMessage
  def initialize
    @go_home      = "csv/go_home.csv"
    @go_to_school = "csv/go_to_school.csv"
    
    randm_file   = "./random.txt"
    open(randm_file, "r") do |file|
      @messages = file.readlines.collect{|line| line.strip}
    end
  end
  
  def create_message(tweet)
    tt  = choice_csv(tweet)
    msg = time_table_search(tt) if tt
    msg = random_message    unless tt
    return msg
  end
  
  private
  
  def choice_csv(tweet)
    home_regex   = /(帰る|帰ります|帰りたい|かえる|かえります|かえりたい)/
    school_regex = /(大学|学校)*.*(行く|行こう|行って|向かう|向かいます|向かおう|いく|いこう|むかう|むかいます|むかおう)/
    
    return read_csv(@go_home)      if tweet =~ home_regex
    return read_csv(@go_to_school) if tweet =~ school_regex
    return false
  end
  
  def read_csv(csvfile)
    time_tables = Array.new
    keys = [:hour, :weekly, :holiday]
    CSV.open(csvfile, "r") do |row|
      next if row.to_s.include?("#")
      time_tables << Hash[*keys.zip(row).flatten]
    end
    return time_tables
  end
  
  def time_table_search(time_tables)
    day = Time.now
    # day = Time.local(2012, 3, 18, 10, 20, 34)
    key = :weekly
    key = :holiday unless day.holiday?
    
    time_tables.each do |tt|
      if tt[:hour].to_i == day.hour
        tt[key].split(" ").each do |min|
          if min.to_i >= day.min + 20
            return "#{tt[:hour]}時#{min}分にのるといいかも。"
          end
        end
      end
      
      if tt[:hour].to_i == (day.hour + 1)
        min = tt[key].split(" ")[0]
        return "今日はもうバスないよ。" if tt[key] == "nil"
        return "#{tt[:hour]}時#{min}分にのるといいかも。"
      end
    end
  rescue StandardError => ex
	puts "[#{Time.now}] #{ex.message}\n#{ex.backtrace}"
	puts ex.backtrace
  end

  def random_message
    return @messages[rand(@messages.size)]
  end
end
