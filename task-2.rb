# frozen_string_literal: true

require 'json'
                          # require 'pry'
                          # require 'date'
require 'set'
require 'ruby-progressbar'

MIN = ' min.'

class User
  @@totalUsers = 0

  attr_reader :fullName
  attr_reader :sessions, :browsers, :dates
  attr_reader :usedIE, :alwaysUsedChrome

  def self.totalUsers
    @@totalUsers
  end

  def initialize(cols)
    @@totalUsers += 1
    @fullName = "#{cols[2]} #{cols[3]}"
    @sessions = []
    @browsers = []
    @dates = []
    @usedIE = false
    @alwaysUsedChrome = nil
  end

  def addBrowser(browser)
    @browsers << browser.upcase!
    if !@usedIE && browser =~ /INTERNET EXPLORER/ 
      @usedIE = true
      @alwaysUsedChrome = false
    elsif @alwaysUsedChrome.nil?
      @alwaysUsedChrome = browser =~ /CHROME/ ? true : false
    elsif @alwaysUsedChrome && browser !=~ /CHROME/
      @alwaysUsedChrome = false
    end        
  end

  def sortBrowsers
    @browsers.sort!
  end 

  def addSession(session)
    @sessions << session.to_i
  end

  def totalTime
    @sessions.sum
  end

  def longestSession
    @sessions.max
  end

  def addDate(date)
    @dates << date
  end

  def inverseDateList
    @dates.sort! {|a, b| b <=> a}
  end

  def sessionsCount
    @sessions.length
  end

  def destroy
    @fullName = nil
    @sessions = nil
    @browsers = nil
    @dates = nil
  end
end

class Report
  attr_reader :uniqueBrowsers
  attr_reader :user
  attr_reader :totalSessions

  def initialize(file_name = 'result.json')
    @f_out = File.new(file_name, File::CREAT | File::WRONLY)
    @uniqueBrowsers = SortedSet.new
    @totalSessions = 0
    @user = nil
    @f_out.write('{"usersStats":{')
  end

  def createUser(cols)
    @user = User.new(cols)
  end

  def addUserStat(cols)
    @user.addBrowser(cols[3])
    @user.addSession(cols[4].to_i)
    @user.addDate(cols[5])
  end

  def closeUserStat(last = false)
        def inverseDateList
          dates.sort! {|a, b| b <=> a}
        end

    @user.sortBrowsers
    @user.inverseDateList

    @f_out.write("#{@user.fullName.to_json}:")
    userReport = {
      sessionsCount: @user.sessionsCount,
      totalTime: "#{@user.totalTime}#{MIN}",
      longestSession: "#{@user.longestSession}#{MIN}",
      browsers: @user.browsers.join(', '),
      usedIE: @user.usedIE,
      alwaysUsedChrome: @user.alwaysUsedChrome,
      dates: @user.dates 
    }
    @f_out.write(userReport.to_json)

    @uniqueBrowsers.merge(@user.browsers) 
    @totalSessions += @user.sessionsCount
    @user.destroy; 
    @user = nil 
    if last
      @f_out.write('},')
    else
      @f_out.write(',')
    end
  end 

  def finalStat
    sessionsReport = {}
    sessionsReport[:totalUsers] = User.totalUsers
    sessionsReport[:uniqueBrowsersCount] = @uniqueBrowsers.count
    sessionsReport[:totalSessions] = @totalSessions
    sessionsReport[:allBrowsers] = @uniqueBrowsers.to_a.join(',')

    @f_out.write(sessionsReport.to_json.delete('{'))
    @f_out.write("\n")
  end 

  def destroy
    @f_out.close

    @uniqueBrowsers = nil
    @totalSessions = nil
  end
end 

def work(filename = 'data.txt', disable_gc: true)
  GC.disable if disable_gc

  file_name = ENV['DATA_FILE'] || filename

  puts("#{Time.now} Потоковая обработка данных") if ENV['PRINT_STATUS']=='TRUE' 

  if ENV['PRINT_STATUS']=='TRUE' 
    lines_count = `wc -l "#{file_name}"`.split.first.chomp.to_i # 
    if lines_count>100 
      parts_of_work = 100
      tile =  lines_count / parts_of_work + 1
    else
      parts_of_work = lines_count
      tile = 0
    end
    progressbar = ProgressBar.create(
      total: parts_of_work,
      format: '%a, %J, %E %B' # elapsed time, percent complete, estimate, bar
    )
  end

  report = Report.new

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  inp = 0
  File.foreach(file_name, chomp: true) do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      if report.user
        report.closeUserStat
      end
      report.createUser(cols)
    when'session'
      report.addUserStat(cols)
    end  
    cols = nil

    if progressbar
      if tile == 0 
        progressbar.increment 
      elsif (inp % tile) == 0
        progressbar.increment 
      end
      inp += 1 
    end
  end
  report.closeUserStat(last = true) if report.user

  report.finalStat
  report.destroy

  puts("#{Time.now} Конец") if ENV['PRINT_STATUS']=='TRUE' 
end
