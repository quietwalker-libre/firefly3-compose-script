# firefly3-compose-script
This is a script which will install and manage a docker compose deployed FireFly3 system

# What is FireFly III
[Firefly](https://www.firefly-iii.org) is a free and open source personal finance manager. 
It offer a lot of feature such as: 
- **Full transaction management**: You can quickly enter and organize your transactions in multiple currencies. 
- **Budget, categories and tags**: Need to budget your expenses? Want to categorize all of your hobby expenses? Look no further. Firefly III supports all kinds
- **Rule Engine**: Use the rule engine to automatically set budgets, remove categories, append descriptions, change notes or something else entirely. 
- **Import transactions**: Firefly III can import from variety of sources using the wonderful Salt Edge API, that allows access to over 2500 financial institutions and counting and it is also capable to import from CSV files
- **Reports**: Firefly III has advanced reporting capabilities, showing your expenses per week, month or year. 
- **JSON REST API**: if you don't know what this mean, then you don't need this feature :P 

# Dependeces 
It ony require 2 packages to be executed: 
- *docker* 
- *docker-compose* 

# How to use
The script, if launched without arguments, it will display a little helper reporting the possible arguments that can be used.
The argument could be: 

```
    --install    Install FireflyIII from scratch
    --start        Start an existing installation of FireflyIII
    --stop        Stop an already running installation of FireflyIII
    --delete    Delete an existing installation of FireflyIII
```

So if you are using this script for the first tie it should be enough to execute it as follow: 


```
    chmod +x firefly-utility-tool.sh
    ./firefly-utility-tool.sh --install
```


# Screenshot
![Screenshot1](screenshots/firefly3-utility-script.png)
![Screenshot2](screenshots/login_page.png)
![Screenshot3](screenshots/dashboard_screenshot.png)
