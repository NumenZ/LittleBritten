# LittleBritten

> Small game that uses Ethereum ledger to store states and ensure that players don't cheat.  

## Table Of Contents
1. [TL;DR](#tldr)
2. [Deadlines](#deadlines)
3. [Implementation Details](#implementation-details)
4. [How-to Use](#how-to-use)
5. [ToDo Log](#todo-log)

## [TL;DR](#table-of-contents)

* Popular pencil game from good oll' times - `Sticks & Squares`.
* All logic is held by smart contracts, frontend only handles the drawing part.
* MetaMask for user-friendliness is integrated.

## [Deadlines](#table-of-contents)

|       Date      | Maximum possible mark |
| :-------------: | :-------------------: |
| 2359 5-th March |         10.0          |

## [Implementation Details](#table-of-contents)

Lets look at the _source code structure_ under `src` folder:
* __contracts__ - Solidity code.
* __static__ - Frontend code and resources lie here.
* __migrations__ - Contract deployment code.
* __SubDockerfile__ - Launches the _cite_ __docker-machine__. 
* __run.sh__ - Script that launches the server.
* __static_server.py__ - Simple server, that serves static.
* __truffle.js__ - Configuration file, for deploying using _truffle_ framework.
* __conf.py__ - Configuration file for _Gunicorn_. 
* __requirements.txt__ - Dependencies, for launching our _python_ code. 
* __vendor__ - under this folder, the external libraries and files lie. I use:
    * I use `bootstrap` package for some styles and minor view modifications.
    * `jquery_1.12.4.js`, the standard lib for working with DOM elements. 
    * `web3.js` for connection to Ethereum network.
    * I make use of `glitch.js`, tiny lib, to make nice logos.
    * And finally, `truffle-contract.js` custom library from truffle to _wrap_ __Solidity__ contracts in __JS__.
    
The system works as follows:
* Running `docker-compose` command will launch two _docker-environments_:
    * __ledger__ - Here the `ganache` Ethereum test-net will be launched. 
    * __cite__ - The simple Flask server will launch, serving our web-game.
* When the __cite__ image, will be build, it will:
    * Pull some dependencies.
    * Compile contracts.
    * Deploy contracts to test-net, that is in separate container.
    * Launch python server on _Flask_, that will serve our frontend logic.

Lastly, let's add a little bit, on how it works:
1. Contracts hold the logic.
    * _Migrations_ contract is needed to correctly deploy code -> nothing interesting here.
    * _Math_ - Small math library that I'm using.
    * _Rules_ - The logic of the game.
    * _TwoPlayerGame_ - Core logic for game. Manipulates low-level game functions.
    * The _StickGame_ contract represents the game itself. It extend the _TwoPlayerGame_ contract, and provides 
        higher level function for game handling.
2. Fronted is primitive.
    * No logic, just updates the screen.  
    * Based on callbacks(solidity events), that receives from the _ledger_.
3. Everything is served under Docker. 
    * One image, creates the ledger using `ganache-cli`.
    * Other one, which is based on the first image, serves the web-page(__No__ logic there, just for convenience).
    * Also it's duty to compile, and upload _Smart-contracts_. 

## [How-to Use](#table-of-contents)

In order to start everything, a little bit of preparations are required:

1. Since I tried to make the game, as most user-friendly as possible, 
    we are using __MetaMask__, to communicate with game. Or more precisely, we 
    need MetaMask's _web3.js_ instance, to easily confirm our transactions, 
    that we send to our test net.
    
    So in order, for everything to work correctly, follow this steps:
    
    * Download [Google Chrome](https://www.google.ru/chrome/index.html) browser.
    * Install the [MetaMask](http://metamask.io/) browser extension.
    * The icon will show in the _top-right_ corner of the browser(where other extensions are).
    * Click on it, and create account.
    * Click the menu that shows "Main Network" and select `Localhost 8545`.
2. Install the `docker` thing.
    * Do `curl https://get.docker.com/ | sh` in the terminal, 
        if you are under some Linux distro.(In other case, look [here](https://docs.docker.com/install/))
    * Install [pip3](https://stackoverflow.com/questions/6587507/how-to-install-pip-with-python-3) 
        for __python3__ and run `sudo pip3 install docker-compose`.
3. Then, at long last, let's run _dis_ game.
    * Assuming you have __git__ run in terminal `git clone https://github.com/NumenZ/LittleBritten`,
        or, well, just somehow get the code part of current project.
    * Now, we need to get a small information from our __MetaMask__ account, 
        in order for us, to launch test-net correctly:
        * Press on ellipsis(_3 dots_), under the foxes head. ![Menu1](/doc/meta-mask-1.png)
        * Find the export Address and Private key to some file.![Menu2](/doc/meta-mask-2.png)
        * Save this parameters as environmental variables -> in your terminal(replace caps):
            * `export TEST_ADDRESS="ADDRESS"`.
            * `export TEST_PRIVATE_KEY="0xPRIVATE_KEY"`.
    * Finally, run `docker-compose up --build`.
4. As a last step, open your __Google Chrome__ browser at 'http://127.0.0.1:8080', and _enjoy the game_.

It must look something like this.
![Menu1](/doc/game_look.png)

In case, you don't know the rules, check them [here](https://en.wikipedia.org/wiki/Dots_and_Boxes).

## [ToDo Log](#table-of-contents)

- [x] __2 points__ - Write simple working example, with simple _web-server_ and _fronted_.

- [x] __2 points__  - Implement the game, with nice GUIs and _Smart-Contracts_ backing up the logic.

- [ ] __3 points__  - Connect _front-end_ with the _back-end_ logic.

- [x] __2 points__  - Make all configuration as simple as possible, using `Docker`, `MetaMask`, _file-serving_, etc.

- [x] __1 point__ - Write this `ReadMe.md` with all explanations.