---
title: 'Java movie playback: JOGL + Fobs4JMF'
date: 2008/08/20
read_more: true
---
Recently I had to integrate video playback on my job's Java OpenGL engine, which uses [JOGL](https://jogl.dev.java.net).

Java has a support to media playback through it's [Java Media Framework](http://java.sun.com/javase/technologies/desktop/media/jmf/), which unfortunately, on it's current version (2.1.1e) does not support many [formats for video playback](http://java.sun.com/javase/technologies/desktop/media/jmf/2.1.1/formats.html).

So I quickly looked for alternatives, including [IBM Toolkit for mpeg4](http://www.alphaworks.ibm.com/tech/tk4mpeg4), that hadn't a sufficient production performance I was looking for, and didn't offer an easy option for frame grabbing or plugin extensions as JMF does. Next was [Fobs4JMF](http://fobs.sourceforge.net/), which is [JMF](http://java.sun.com/javase/technologies/desktop/media/jmf/) + [ffmpeg](http://ffmpeg.org). This solution was much more interesting, since it offers a wide variety of codecs (ogg, mp3, m4a, divx, xvid, h264, mov, etc) and is based on the solid ffmpeg solution to decode audio and video.

READMORE

My implementation, uses the plug-in capabilities of JMF to extend a custom renderer that does a pixel type conversion and rendering to a texture:

<div style="text-align: center;"><object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="425" height="344" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"><param name="allowFullScreen" value="true" /><param name="src" value="http://www.youtube.com/v/-zh6yDyasSo&amp;hl=en&amp;fs=1" /><param name="allowfullscreen" value="true" /><embed type="application/x-shockwave-flash" width="425" height="344" src="http://www.youtube.com/v/-zh6yDyasSo&amp;hl=en&amp;fs=1" allowfullscreen="true"></embed></object></div>

This custom renderer works with RGB textures, a type I seemed to made work on my two test machines:

* MacBook with a Integ GMA x3100 - Leopard;
* PC with a Radeon x600 - Debian.

You might wanna try different pixel types to increase the performance on different target machines.

First, lets describe how the Renderer works. It got to be an implementation of a `javax.media.renderer.VideoRenderer` since it will be installed as a plugin on JMF.

For the different methods we need to implement, there are a few we need to take proper care of:

* **process**: this is the method JMF calls passing the movie's current frame buffer, here we process the buffer so that we can latter render it in OpenGL;
* **getSupportedInputFormats**: we return `RGBFormat`, our target texture format;
* **setInputFormat**: here we simply tell JMF that the format it chooses is the one we want. Since RGB was the only one we returned as supported, there is not much to do here as well.
* **getName**: returns the renderer neat name!

Next we need a way to access this renderer outside of the JMF context, so that we can get the texture and render it on the teapot. To achieve it, our class must also be a `javax.media.Control` implementation, then we can easily get it through a `getControl` call, such as:

    player.getControl("javax.media.renderer.VideoRenderer");

So we implement:

* **getControl**: returns it's instance;
* **getControls**: returns an array containing only it's instance as a valid control.

The renderer implementation is [org.pirelenito.multimedia.jmf.plugin.RGBGLTextureRenderer](http://github.com/pirelenito/MovieGL/blob/master/src/org/pirelenito/multimedia/jmf/plugin/RGBGLTextureRenderer.java).

And also, to make further development easy, there is an [IGLTextureRenderer](http://github.com/pirelenito/MovieGL/blob/master/src/org/pirelenito/multimedia/jmf/plugin/IGLTextureRenderer.java) interface with the public methods called by the Canvas:

* **render**: that plots the buffer on the texture surface;
* **getTexture**: to retrieve the texture instance.

Last but not least, you will need to register the renderer on JMF, this is done through the JMFRegistry application. The easiest way to start it, since our custom renderer is already on the class path, is inside Eclipse:

* Create a new run configuration;
* Set the main class as: `JMFRegistry`;
* Start it, and go to the Plugins tab, then Renderer;
* Add the `org.pirelenito.multimedia.jmf.plugin.RGBGLTextureRenderer`;
* Move it to the top of the list;
* Push Commit, and you are good to go!

To test it out there is also a [helper class](http://github.com/pirelenito/MovieGL/blob/master/src/org/pirelenito/multimedia/jmf/MoviePlayer.java) to instantiate the movie player, and a [main class](http://github.com/pirelenito/MovieGL/blob/master/src/org/pirelenito/movieGL/Main.java) that is an OpenGL canvas used to render the teapot with the texture on its surface.

I am not very experienced with OpenGL, so there might be more effitient ways to do this, using for instance PBO (Pixel Buffer Object).

You can check the code at [http://github.com/pirelenito/MovieGL](http://github.com/pirelenito/MovieGL)

Cheers! ;)

ps: I moved this article from an old Wordpress blog, and for now there are no comments available.
