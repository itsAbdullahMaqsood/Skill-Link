Map<String, dynamic> googleOAuthExchangeBody(String idToken) => <String, dynamic>{
      'id_token': idToken,
      'idToken': idToken,
      'token': idToken,
      'credential': idToken,
    };
