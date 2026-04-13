package name.neykov.secrets.util;

import javax.net.ssl.*;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;

public class HttpPostTest {

    // 全局信任所有证书（无 Lambda，纯匿名内部类）
    static {
        try {
            TrustManager[] trustAllCerts = new TrustManager[]{
                    new X509TrustManager() {
                        public X509Certificate[] getAcceptedIssuers() {
                            return null;
                        }
                        public void checkClientTrusted(X509Certificate[] certs, String t) {
                        }
                        public void checkServerTrusted(X509Certificate[] certs, String t) {
                        }
                    }
            };

            SSLContext sc = SSLContext.getInstance("SSL");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

            // 忽略主机名验证（纯匿名类）
            HostnameVerifier allHostsValid = new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            };
            HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static void postUrl(String urlPath, String secret) {
        try {
            String[] split = urlPath.split("@");
            if (split.length == 2 && split[1].equals("true")) {
                URL url = new URL(split[0]);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();

                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                conn.setDoOutput(true);
                conn.setConnectTimeout(500); // 连接目标服务器超时 1秒
                conn.setReadTimeout(500);    // 读取数据超时 1秒

                // 请求体
                String json = "{\"data\":\"" + secret + "\"}";

                // 发送
                DataOutputStream out = new DataOutputStream(conn.getOutputStream());
                out.writeBytes(json);
                out.flush();
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream())
                );
                String result = reader.readLine();
                System.out.println("返回：" + result);

                reader.close();
                out.close();
                conn.disconnect();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }



    public static void main(String[] args) {
        postUrl("http://localhost:8091/tlsKey.do", "123");

    }
}