#!/usr/bin/ruby -Ku
#一日前のツイートをまとめて取得し、WordPressのブログに投稿するスクリプトです。LinuxやFreeBSDというUNIX環境が前提ですCRONで自動実行することを考えて作りました。
#引数をとると指定したTwitterユーザのツイートを取得できますが、この場合次の例のように、ユーザ名、指定日付、指定タイトルという3つの引数をつけるようにしてあります。
# h-twit-s_hirono-xmlrpc.rb hirono_hideki 20110817 "テストです。たいとる"
#実際に使用しているブログです。→ http://hirono2011.wordpress.com/
#なお、APIでのデータの取得はサーバの状態などによってもうまくいかない場合があるかと思います。APIの使用回数にも制限がありますので気をつける必要があるかと思います。

require 'rubygems'
require 'twitter'
require 'twitter-text'
require 'clipboard'
require 'xmlrpc/client'
require 'time'
require 'pp'

$html_data = ""

t=Time.now
if ARGV[1] == nil then
	day=t.strftime("%Y/%m/%d %H:%M").slice(0, 10).delete("/").to_i - 1
else
	day = ARGV[1].to_i
end

def html_link(x)
	include Twitter::Extractor
	usernames = extract_mentioned_screen_names(x)
	include Twitter::Autolink
	html = auto_link(x)
	return html
end


# ログイン
Twitter.configure do |config|
  config.consumer_key = '取得したConsumer key'
  config.consumer_secret = '取得したConsumer secret'
  config.oauth_token = '取得したAccess Token (oauth_token)'
  config.oauth_token_secret = '取得したAccess Token Secret (oauth_token_secret)'
end 

def get_twits_page(page, day)

	s = 0

	list=Array.new
	uname=ARGV[0] ||'s_hirono'
	list=Twitter.user_timeline(:user=>uname, :include_rts=>1, :page=>page)


	h=Hash.new
	hh=Array.new
	html=""

	html +=  <<EOF
<ol style="list-style: none outside none; margin: 0pt; padding: 0pt;">
EOF

	list.each do |i|
		h["ctime"] = Time.at(Time.parse(i.created_at).to_i).strftime("%Y/%m/%d %H:%M");

		data_day = h["ctime"].slice(0, 10).delete("/").to_i
#puts "指定日時#{day}  ==== データ日時#{data_day}"
		if day > data_day then
			s = 1
		end

		if day == data_day then
			h["id"] = i.id
			h["img"] = i.user.profile_image_url;
			h["sname"] = i.user.screen_name;
			h["name"] = i.user.name;
			h["text"] = html_link(i.text);
			h["url"] = "http://twitter.com/#{i.user.screen_name}/status/#{i.id}";
			h["source"] = i.source;
			#print ">>>" , data_day
			html +=  <<"EOF"
<li style="position: relative; line-height: 1.1em;">
<span style="display: block; height: 60px; left: 0pt; margin: 10pt 10px 0pt 5px; overflow: hidden; position: absolute; width: 50px;"><a href="http://twitter.com/#{h["sname"]}/"><img src="#{h["img"]}" alt="#{h["sname"]}" style="width: 48px; height: 48px; border: 0pt none;"></a></span><span class="status-body" style="display: block; margin-left: 65px; min-height: 50px; height: auto ! important;">
<span style="font-size: 0.7em;"><span style="color: #FF4500;font-weight:bold">#{h["sname"]}</span><span style="margin-left:5px;color: rgb(153, 223, 153); font-size: 0.66em;"> #{h["name"]}</span></span>
<span>#{h["text"]}</span><span style="display: block; font-size: 0.66em; color: rgb(153, 153, 153); margin: 0px 0pt 0pt;"><a href="http://twitter.com/#{h["sname"]}/status/#{h["id"]}" target="_blank"><span>#{h["ctime"]}</span></a> <span> via #{h["source"]}</span></span></span>
</li>
EOF

			if i.retweeted_status then
				rt = i.retweeted_status
				hh = Hash.new
				rt_data = Twitter.user_timeline(:user=>rt.user.screen_name, :max_id=>rt.id, :count=>1)

				hh["id"] = rt.id
				hh["img"] = rt.user.profile_image_url;
				hh["sname"] = rt.user.screen_name;
				hh["name"] = rt.user.name;
				hh["text"] = html_link(rt.text);
				hh["ctime"] = Time.at(Time.parse(rt.created_at).to_i).strftime("%Y/%m/%d %H:%M");
				hh["url"] = "http://twitter.com/#{rt.user.screen_name}/status/#{rt.id}";
				hh["source"] = rt.source;

				html += <<"EOF"
<li style="position: relative; line-height: 1.1em; margin: 20px 5px 10px 60px">
<span style="font-style: italic; color: red; background-color: #FEECFF">&lt;このツイートの公式RTです。一致しない場合は削除の可能性があります。&gt;</span><br />
</li>
<li style="position: relative; line-height: 1.1em; margin: 20px 5px 10px 60px; background-color: #E3F1FF;">
<span style="display: block; height: 60px; left: 0pt; margin: 10pt 10px 0pt 5px; overflow: hidden; position: absolute; width: 50px;"><a href="http://twitter.com/#{hh["sname"]}/"><img src="#{hh["img"]}" alt="#{hh["sname"]}" style="width: 48px; height: 48px; border: 0pt none;"></a></span><span class="status-body" style="display: block; margin-left: 65px; min-height: 50px; height: auto ! important;">
<span style="font-size: 0.7em;"><span style="color: #FF4500;font-weight:bold">#{hh["sname"]}</span><span style="margin-left:5px;color: rgb(153, 223, 153); font-size: 0.66em;"> #{hh["name"]}</span></span>
<span>#{hh["text"]}</span><span style="display: block; font-size: 0.66em; color: rgb(153, 153, 153); margin: 0px 0pt 0pt;"><a href="http://twitter.com/#{hh["sname"]}/status/#{hh["id"]}" target="_blank"><span>#{hh["ctime"]}</span></a> <span> via #h{h["source"]}</span></span></span>
</li>
EOF
			end

		else

			next

		end

	end

	html +=  "</ol>\n"
	$html_data += html

	return s

end

html_data=""
p = 1
while true do
	s = get_twits_page(p, day)
	break if s == 1
	p = p + 1
end

#ブログにxmlrpcで投稿
if $html_data == ""  then
	exit 1
end


user = 'ユーザ名'
pass = 'パスワード'
publish = 1 #0にすると下書き投稿になるみたいです。確認はしていないです。

server = XMLRPC::Client.new('ユーザ名.wordpress.com', '/xmlrpc.php')

title_name = ARGV[2] || "#{day}のツイート_再審請求_金沢地方裁判所御中 (s_hirono)"
struct = {
'title'=>title_name,
'description'=>$html_data
}

id = server.call("metaWeblog.newPost",1,user,pass,struct,publish)


