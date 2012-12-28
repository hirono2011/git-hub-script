package net.hirono;

import java.awt.AWTException;
import java.awt.Dimension;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import java.util.Calendar;
import java.text.SimpleDateFormat;

/* コマンドを実行したカレントディレクトリにjpeg形式のスクリーンショットファイルを作成。
 * 日付時刻をファイル名に含める。コマンドライン引数でファイル名を指定、省略時はxxx。
 * Eclipseで実行可能JARファイルを作成。CLASSPATHにjarファイルを追加
 * 　次のように実行。
 * java net.hirono.HscreenShot ファイル名
 * 例：　ファイル名_2012-12-28_18:36:59.jpg
 */

public class HscreenShot {
    public static void main(String[] args) throws AWTException, IOException {
        Robot robot = new Robot();
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        BufferedImage image = robot.createScreenCapture(
            new Rectangle(0, 0, screenSize.width, screenSize.height));

	//現在日時を取得する
        Calendar c = Calendar.getInstance();
	//フォーマットパターンを指定
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH:mm:ss");
	String ftime = sdf.format(c.getTime());

	String name = args[0];

	if (name.isEmpty()) {
		name = "xxx";
	} else {
		//何もしない
	}
	
	String fname = name + "_" + ftime + ".jpg";

        ImageIO.write(image, "JPG", new File(fname));
    }
}


