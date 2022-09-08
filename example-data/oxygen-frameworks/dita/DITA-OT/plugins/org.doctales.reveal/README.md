org.doctales.reveal
===========================

This is a plugin for the DITA-OT. The plugin adds a new transtype called `reveal` for transforming DITA maps into reveal.js based web presentations.


Installation
============

1. Move to the `~/plugins` directory of the DITA-OT.
2. Clone this repository.  
   `git clone https://github.com/doctales/org.doctales.reveal`
3. Launch the `startcmd.sh` (Linux/Mac OSX) or `startcmd.bat`.  
   `./startcmd.sh`
4. Call the integrator to install the plugin.  
   `ant -f integrator.xml`


Using the Plugin
================

Create a new target in your Ant build file. The following target shows all currently supported properties of the plugin. You do not have to set the optional properties, if you feel 
comfortable with the default settings.

```xml
<?xml version="1.0" encoding="UTF-8"?>


<target name="reveal" description="Generate a reveal.js based web presentation.">
    <antcall target="integrate"/>
    <ant antfile="${dita.dir}\build.xml">
        <!-- The input DITA map. -->
        <property name="args.input" value="[YOURMAP].ditamap"/>
        
        <!-- The output directory. -->
        <property name="output.dir" value="out/reveal"/>
        
        <!-- The transformation type. -->
        <property name="transtype" value="reveal"/>
        
        
        <!-- OPTIONAL PROPERTIES -->
        
        <!-- Path to custom template file -->
        <property name="reveal.css" value="my-template.css"/>
        
        <!--
            The template. Possible values:
            "default", "sky", "beige", "simple",
            "serif", "night", "moon", "solarized"
            If you use a custom template, the name
            of the template is the filename without its
            extensions, e.g. "my-template"
        -->
        <property name="args.reveal.css" value="default"/>
        
        <!-- Display controls in the bottom right corner. -->
        <property name="args.reveal.controls" value="true"/>
        
        <!-- Display a presentation progress bar. -->
        <property name="args.reveal.progress" value="true"/>
        
        <!-- Display the page number of the current slide. -->
        <property name="args.reveal.slidenumber" value="false"/>
        
        <!-- Push each slide change to the browser history. -->
        <property name="args.reveal.history" value="false"/>
        
        <!-- Enable keyboard shortcuts for navigation. -->
        <property name="args.reveal.keyboard" value="true"/>
        
        <!-- Enable the slide overview mode. -->
        <property name="args.reveal.overview" value="true"/>
        
        <!-- Enable the vertical centering of slides. -->
        <property name="args.reveal.center" value="true"/>
        
        <!-- Enable touch navigation on devices with touch input. -->
        <property name="args.reveal.touch" value="true"/>
        
        <!-- Loop the presentation. -->
        <property name="args.reveal.loop" value="false"/>
        
        <!-- Change the presentation direction to be right-to-left. -->
        <property name="args.reveal.rtl" value="false"/>
        
        <!-- Turn fragments on and off globally. -->
        <property name="args.reveal.fragments" value="true"/>
        
        <!--
            Flags if the presentation is running in an embedded mode,
            i.e. contained within a limited portion of the screen.
        -->
        <property name="args.reveal.embedded" value="false"/>
        
        <!--
            Number of milliseconds between automatically proceeding to the
            next slide, disabled when set to 0, this value can be overwritten
            by using a data-autoslide attribute on your slides.
        -->
        <property name="args.reveal.autoslide" value="0"/>
        
        <!-- Stop auto-sliding after user input. -->
        <property name="args.reveal.autoslidestoppable" value="true"/>
        
        <!-- Enable slide navigation via mouse wheel. -->
        <property name="args.reveal.mousewheel" value="false"/>
        
        <!-- Hide the address bar on mobile devices. -->
        <property name="args.reveal.hideaddressbar" value="true"/>
        
        <!-- Open links in an iframe preview overlay. -->
        <property name="args.reveal.previewlinks" value="false"/>
        
        <!--
            Set the transition style. Possible values:
            "default", "cube", "page", "concave",
            "zoom", "linear", "fade", "none"
        -->
        <property name="args.reveal.transition" value="default"/>
        
        <!--
            Set the transition speed. Possible values:
            "default", "fast", "slow"
        -->
        <property name="args.reveal.transitionspeed" value="default"/>
        
        <!--
            Set the transition style for full page
            slide backgrounds. Possible values:
            "default", "none", "slide", "concave", "convex", "zoom"
        -->
        <property name="args.reveal.backgroundtransition" value="default"/>
        
        <!-- Set the number of slides away from the current that are visible. -->
        <property name="args.reveal.viewdistance" value="3"/>
        
        <!--
            Set the parallax background image.
            Example:
            "'https://s3.amazonaws.com/hakim-static/reveal-js/reveal-parallax-1.jpg'"
        -->
        <property name="args.reveal.parallaxbackgroundimage" value=""/>
        
        <!--
            Set the parallax background size.
            Example:
            "2100px 900px"
        -->
        <property name="args.reveal.parallaxbackgroundsize" value=""/>
    </ant>
</target>
```

