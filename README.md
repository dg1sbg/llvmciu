# <img src="https://github.com/dg1sbg/llvmciu/raw/master/realclone.jpg"/>  LLVMCIU

<p><h2><b>Gönninger B&T's LLVM CLONE AND INSTALL UTILITY</b></h2>

## NOTE:  December 31, 2017 - This contains Release A.01.00 of LLVMCIU.

## What Is This?
LLVMCIU is a bash shell script that makes cloning, building and installing LLVM and tools like Clang, libcxx, libcxxabi and stuff easy. It has an interactive mode where you can see which directories are selected and where the sources will be installed to and much more ... It is tested under macOS High Sierra only, but should work on any linux with bash shell.<br><br>
If there is already source code cloned then the script will do a git pull. You may force cloning by specifying command line argument -d or --delete.

## Usage
LLVMCIU is simply executed as <br>
<pre>./llcmciu.sh</pre><br>
The command line options are:<br>
<pre>

 -n | --non-interactive -> Execute in batch mode
 -c | --cleanup         -> Do cleanup on error
 -s | --src-cleaning    -> Do rm -rf on source directories on error
 -f | --force-cleanup   -> Force doing cleaning and cleanup on error
 -d | --delete          -> Force deleting of sources and therefore force cloning
 -b | --build           -> Execute Build step
 -i | --install         -> Execute Install step

</pre>

## License
<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />LLVMCIU is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>. Any violation of this license will be prosecuted. German law applies in all cases and under all circumstances.

## Reporting Problems
Generally you can report problems in two fashions, either by [opening an issue ticket](https://github.com/dg1sbg/llvmciu/issues/new) or by [emailing to GB&T's support](mailto:support@goenninger.net). In both cases, though, you should have the following pieces handy in order for us to be able to help you out as quickly and painlessly as possible:

* Your operating system name and version.
* The branch of LLVMCIU that you're using.
* A paste of the build log or failure point that you reached.
* Patience.

## Contact
You may contact us via email at [support@goenninger.net](mailto:support@goenninger.net) or via our website [www.goenninger.net](https://www.goenninger.net). See also [frgo's blog](http://ham-and-eggs-from-frgo.blogspot.de) for an occasional post about LLVMCIU.
