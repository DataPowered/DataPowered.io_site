+++
date = "2017-11-26"
draft = false
title = "Using R remotely: some options and tips"
tag = ["R", "RStudio", "ssh", "vim"]
author = ["Caterina"]
+++


Why would you need to do this? Say, for instance, you are dealing with sensitive data that should not leave a specific system, or quite simply that you are away on a work retreat - but your laptop is far less powerful than your work desktop computer which you left behind - so you want to keep using it from a distance. For such reasons, I've been looking into what options are available to log in remotely to a machine and run `R` there for some analysis. Below are some of the alternatives I've come across: 

**1.** Remote desktop applications; </br>
**2.** "Plain" `ssh`; </br>
**3.** `ssh` with X11 forwarding; </br>
**4.** `R` used with `vim` and `tmux`; </br>
**5.** Executing `R` code remotely from a local instance.


## 1. Remote desktop applications (RDAs)

Remote desktop applications (like [VNC](https://www.realvnc.com/en/) or [Remmina](https://www.remmina.org/wp/) etc.) allow you to visualise another machine's desktop environment from afar. For example, if one day you are working from home, you can use an RDA from your home machine to log into, and use your work machine. This would let you interact with its environment as though you were in front of the work machine's screen.

I usually save this option for when I need access to a range of things from a remote system, but since 99% of the time I only need access to `R` on a remote machine (and nothing else), I've drifted away from RDAs, personally.


## 2 .`ssh` 

This one refers to using a secure shell to log into the remote machine. However, all you get here by default is just that... the shell. You don't see anything other than a command line - so this can be a great option for those who are comfortable with that. Otherwise it might be easier to resort to an RDA. 

I think `ssh`-ing is a lot more streamlined than dealing with a whole windowed desktop environment (as you would with the previous method). That said, there are downsides too - particularly if, like me, you're used to working in an IDE like [RStudio](https://www.rstudio.com/). The "basic" things that I appreciate about RStudio will be absent in a shell - such as having a pane for `R` scripts (to save and reuse) which is separate from the `R` console, or having a built-in graphics pane.

Regardless, in its simplest form, `ssh`-ing into a system would require this code in a Linux terminal:

{{< highlight bash "background = "black" " >}}
$ ssh yourUserName@remoteAddress
{{< / highlight >}}


## 3. `ssh` with X11 forwarding

Not to worry though. There is one trick to get around `ssh` being _too_ stripped down. I'll stick with the RStudio example (since that's easiest for me): assuming you have RStudio installed on the remote system, you can start it up on the remote and have its window _forwarded_ onto your own local machine. This would simply show up as any other program you've got open locally. To achieve this, you'd need to supply one extra option in your `ssh` call (read [here](https://unix.stackexchange.com/questions/12755/how-to-forward-x-over-ssh-to-run-graphics-applications-remotely) for more details):

{{< highlight bash "background = "black" " >}}
$ ssh -X yourUserName@remoteAddress
$ rstudio
{{< / highlight >}}

Pretty neat, right? This way you can avoid running something like VNC when all you actually need is an instance of a single IDE. But there is a catch: depending on various parameters (e.g., your network, the type of cipher used to establish the secure connection), the forwarded window may be extremely slow to respond. In my case, it took forever to even scroll through a script in RStudio, so this could not be a long-term solution.Thankfully though, there are additional options we can add to the call to try and fix this:

{{< highlight bash "background = "black" " >}}
$ ssh -XC yourUserName@remoteAddress
{{< / highlight >}}

As before, the code above enables X11 forwarding, but at the same time ensures that the visual feedback is compressed, and therefore travels faster between the remote and the local machine. It was surprising to me how efficiently this reduced the lag for my session: in terms of user experience, RStudio was now behaving just as though it had been launched locally. 

If this is not enough, you can also try to switch to a different cipher - which is still secure (though opinions vary somewhat here), but faster than the default AES (according to [this source](http://xmodulo.com/how-to-speed-up-x11-forwarding-in-ssh.html)). To do this, you'd need to type:

{{< highlight bash "background = "black" " >}}
$ ssh -XC -c blowfish-cbc yourUserName@remoteAddress
{{< / highlight >}}



## 4. Teaming up `R`, `Vim` and `tmux`

But what if you don't want X11 forwarding  enabled, for instance if the remote machine is not one you trust unreservedly (see [here](https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding) for risks)? Or perhaps if  the X11 option above is still too laggy despite compressing the image stream and changing the cipher? Well, in that case... I might have another solution for you: runing `R` via `Vim` (with the `Nvim-R` plugin) within your `ssh` shell - and all this with a helping hand from `tmux` too. 

What does this mean? After `ssh`-ing in, by running `tmux` you will be able to split your Terminal window into separate panes - one of which I like to keep as an actual Terminal (just in case I end up needing to perform some file operations etc.). The other one can be used to start up Vim (powerful text / script editor) and display my `R` script in it. On typing `\rf` in Vim, that further splits the view to allow for a new pane - one in which an `R` session / console has started. So you'd end up with three panes this way, all in the same window: a Terminal, a script editor, and an `R` console. This may not be the same as running RStudio, but it comes pretty close. I've only just started exploring this option, but am really enjoying it so far! 


## 5. Running RStudio locally, but sending code remotely for execution

This is an option I am aware of, but which I have not yet used myself. I'll just be mentioning it here in case it is useful for you. The poster child for this would probably be RStudio Server, which you can download and use in your browser, but your code actually gets executed by the remote machine / server. It comes in an [open source](https://support.rstudio.com/hc/en-us/articles/200552306-Getting-Started) and [commercial](http://docs.rstudio.com/ide/server-pro/) version.

A possible alternative is the [`remoter` package](https://cran.r-project.org/web/packages/remoter/vignettes/remoter.html),which allows you to control a remote `R` session from a local one. The local R session can run in a terminal, GUI, or IDE such as RStudio. 

<!-- Related: pbdR is a series of R packages that enable the usage of the R language on large distributed machines, like clusters and supercomputers. See r-pbd.org/) for details.-->

<!-- SLIGHTLY DIFFERENT TOOL - prly not super relevant here:
Use sshfs to mount the remote folder on your local machine. This allows you to edit the remote files using your local text editor instead of ssh command line. 

Usage of the Remote Mount Point
The remote mount behaves similarly to locally mounted storage: you are able to create, copy, move, edit, compress or perform any file system operations you would be able to do on the droplet, but you are not able to launch programs or scripts on the remote server.
One typical usage of this would be if you host a website on your VPS and need to make changes to the website on a regular basis. Mounting the file system locally allows you to launch whatever code editor, IDE, or text editor you wish to edit the site, and any changes you make will reflect on the virtual server as soon as they are made on your local machine.
Similarly, on droplets used for testing purposes of coding projects, it allows for much simpler code modifications which can be tested immediately without the need to modify the code locally as well as remotely (and eliminates the hassle of uploading new copies of files for small code changes). -->


---

Hope you found it useful to go through these options for running `R` remotely. What's your favourite?


---

**Disclaimer:** This material is not meant as a user guide, it is rather a summary of my own attempts at learning how to run `R` sessions remotely. Readers are advised to do their own research and decide for themselves what option(s) provide(s) the best compromise in terms of both security and performance.




> This content was first published on [The Data Team @ The Data Lab blog](https://thedatateam.silvrback.com/using-vim-with-r).