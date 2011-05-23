#!/usr/bin/ruby -Ku

require 'rubygems'
require 'twitter'
require 'twitter-text'
require 'clipboard'

#フォローしているけどフォローされていないTwitterアカウントの一覧をHTML形式でクリップボードに格納します。

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

html = ""

guilty = Twitter.friend_ids(ARGV[0]).ids - Twitter.follower_ids(ARGV[0]).ids

t=Time.now
date = t.strftime("%Y年%m月%d日(#{%w(日 月 火 水 木 金 土)[t.wday]}) %H時%M分%S秒")
html += "<div id=\"list\" style-\"margin-top:10px;\"><span style=\"color: red;\">#{date}現在：<a href=\"http://twitter.com/#{ARGV[0]}/\" target=\"_blank\">@#{ARGV[0]}</a>には、#{guilty.length}人の非フォロワーがいます。</span>なお、情報はこの時点でTwitterAPIから取得したものです。最新の情報とは異なる場合があります。アイコンをクリックすると別ウィンドウまたはタブでアカウントのページが開きます。＠のスクリーンネームをクリックするとページがアカウントのページに移動します。<br />
<br />
記事本文はAPI実行時に取得したテキストなので変わることはないですが、アイコン画像はURLのリンクになるので、アカウントの設定変更に伴い置き換わる可能性もあると思います。
</div><br />\n"

html += "<table>\n"
html += "<tr><th>icon</th><th>screen_name</th><th>name</th><th>description</th><th>friends</th><th>followers</th></tr>"
guilty.each do |user_id|
	begin
	  user = Twitter.user(user_id)
		screen_name = html_link("@#{user.screen_name}")
		html += <<EOF
<tr>
	<td style="width: 60px;><a href="http://twitter.com/#{user.screen_name}/" target="_blank"><img src="#{user.profile_image_url}" alt="#{user.screen_name}" style="width: 48px; height: 48px; border: 0pt none;"></td>
	<td>#{screen_name}</td>
	<td>#{user.name}</td>
	<td>#{user.description}</td>
	<td>#{user.friends_count}</td>
	<td>#{user.followers_count}</td>
</tr>
EOF

	rescue => evar
		p $!
		p evar
	end
end

html += "</table>\n"


#樋詰　哲朗 @waterford4u 弁護士
bat_list = %w(yjochi TriggerJones42)
html += "<div id=\"block\" style-\"margin-top:40px;\"><span style=\"color: red;\">こちらはリストに登録したけれど、ブロックされたTwitterアカウントの一覧です。ブロックされるとリストからも自動的に除外されます。</span></div><br />\n"
html += "<table>\n"
html += "<tr><th>icon</th><th>screen_name</th><th>name</th><th>description</th><th>friends</th><th>followers</th></tr>"
bat_list.each do |user_id|
	begin
	  user = Twitter.user(user_id)
		screen_name = html_link("@#{user.screen_name}")
		html += <<EOF
<tr>
	<td style="width: 60px;><a href="http://twitter.com/#{user.screen_name}/" target="_blank"><img src="#{user.profile_image_url}" alt="#{user.screen_name}" style="width: 48px; height: 48px; border: 0pt none;"></td>
	<td>#{screen_name}</td>
	<td>#{user.name}</td>
	<td>#{user.description}</td>
	<td>#{user.friends_count}</td>
	<td>#{user.followers_count}</td>
</tr>
EOF

	rescue => evar
		p $!
		p evar
	end
end

html += "</table>\n"


Clipboard.copy(html);

puts "#{ARGV[0]}の非フォロワーをクリップボードに格納しました。"


