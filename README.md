[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://stand-with-ukraine.pp.ua)

# Simple docker laravel server

Well tested on Ubuntu, Fedora, Manjaro


## 📜 Introduction
I'm Larserve and I'm here to help you get Laravel up and running. You know you're a developer when you can't wait to get home and start working on your new project. But then you realize, whoa, I'm going to have to set this up myself?

I've been around the block, and I know that it can be hard to get started with any frameworks. Setting up the environment, configuring your database, and ensuring all your services are running can be a hassle, especially if you're working with a non-trivial application. That's why I'm here: because I want to make sure that when you start working on your next project, you have everything you need ready to go.

Laraserve is a bash tool that makes it easy to set up and start working with a Laravel application right now. It uses Docker and contains useful services like: (PHP, MySQL, Redis, Mailhog, Nginx..) you can choose which services you want to install, and it will install them for you. Laraserve provides a great starting point for building a Laravel application. It automatically installs all necessary technologies included (like Git, NPM, Docker) if you haven't installed them yet, so you can get started right away. Laraserve even automatically generates new domains in your etc configuration file and SSL certification for the localhost environment, so that you can work on your project without having to worry about security until it's ready for production. .


## 🍬 Benefits


* Automatic installation of all necessary technologies. 🤖
* Command line interface script for automatic projects' generator. 👩‍💻
* Choice of laravel version. 📚
* Multi projects support 💼
* Xdebug debugger support 🐞
* SSL certificate 🔒
* All services are ready to use, and possibility to chose which you want to use in your project 🖥️
* Makefile is a set of commands that are useful for further work with the project. 📝
* Command line interface script for deleting project ❌



## ⚙ Installation

Clone or download the repository and enter its directory:

```bash
git clone https://github.com/MishaIvasyutyn/LaraServe .
bash onceinstall.sh
```