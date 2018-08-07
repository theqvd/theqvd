Configuration file
==================

WAT application have a configuration file named config.json.

This config file has the following format (without final slash):

    {
        "apiUrl": "https://myqvd.com:3000"
    }

This is a JSON formated parameters to get the API Address and Port.

If apiUrl parameter is empty string, system will asume that API URL is the same as the WAT URL.