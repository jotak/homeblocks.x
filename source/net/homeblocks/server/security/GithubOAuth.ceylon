import ceylon.json {
    Object
}
import ceylon.promise {
    Promise,
    Deferred
}

import io.vertx.ceylon.auth.oauth2 {
    OAuth2ClientOptions,
    oAuth2Auth,
    AccessToken
}
import io.vertx.ceylon.core {
    Vertx
}
import io.vertx.ceylon.core.http {
    get
}

import net.homeblocks.server.util {
    promises
}

class GithubOAuth(Vertx vertx, String secret) extends OAuthProvider(
            "gh",
            "GitHub",
            oAuth2Auth.create(vertx, "AUTH_CODE", OAuth2ClientOptions {
                clientID = "d0830e4dc511457c16ad";
                clientSecret = secret;
                site = "https://github.com/login";
                tokenPath = "/oauth/access_token";
                authorizationPath = "/oauth/authorize";
                headers = Object {
                    "User-Agent" -> "jotak-homeblocks"
                };
            })) {

    shared actual Promise<String> getUID(AccessToken token) {
        value def = Deferred<String>();
        if (exists strToken = token.principal().getStringOrNull("access_token")) {
            oAuth2.api(get, "https://api.github.com/user", Object { "access_token" -> strToken },
                (Throwable|Object res) {
                    if (is Throwable res) {
                        promises.reject(def, res);
                    } else if (exists id = res.getIntegerOrNull("id")) {
                        def.fulfill(id.string);
                    } else {
                        promises.reject(def, "'login' field not found");
                    }
                });
        } else {
            promises.reject(def, "Missing access_token");
        }
        return def.promise;
    }
}
