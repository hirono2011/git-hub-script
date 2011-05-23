#!/bin/bash
if [ $# -ne 1 ]; then
    echo "引数に画像ファイル名を一つ指定してください。"
    exit 1
else
    echo "${1}をフォト蔵にアップロードします。"
fi

TEMPFILE="$$.tmp"

 curl -X POST --user 登録メールアドレス:登録パスワード  -F "album_id=アップロードしたいアルバムのID" -F "photo=@${1}" \
 http://api.photozou.jp/rest/photo_add > ./$TEMPFILE

 res=$( sed -e '1,/^.*\[CDATA\[/d' -e 's/^.*\[CDATA\[//' -e 's%]]></medium_tag>%%' -e 's%</rsp>%%' \
  -e 's/width=\"[0-9]*\" height=\"[0-9]*\"/width=\"800" height=\"450\"/' $TEMPFILE \
  | perl -p -e \
's/^(.+show\/\d+?\/)([^"]+)(.*<img src=")(http:[^"]+)(.*)/$1$2$3http:\/\/art16.photozou.jp\/bin\/photo\/$2\/org.bin?size=800$5/;' \
| nkf -w)
 echo $res | xsel -i
 echo $res

rm ./$TEMPFILE

#widthとheightはブラウザで表示される画像サイズになるので適宜変更

