Media plugin which converts the DITA object element to various HTML 5 structures like <video>, <audio> or <iframe>.

The plugin works with both DITA OT 1.8 and 2.x.
Examples:

 1. The DITA structure:
        <object outputclass="audio" type="audio/mpeg" data="Sleep Away.mp3"/>
        
        is converted to:
        
        <audio controls="controls"><source type="audio/mpeg" src="Sleep Away.mp3"></source></audio>
        
 2. The DITA structure:
       <object outputclass="video" type="video/mp4" data="Clip_480_5sec_6mbps_h264.mp4"/>
      
      is converted to:
      
      <video controls="controls"><source type="video/mp4" src="Clip_480_5sec_6mbps_h264.mp4"></source></video>
      
3. The DITA structure:
 
      <object outputclass="iframe" data="https://www.youtube.com/embed/m_vv2s5Trn4"/>
      
      is converted to:
      
      <iframe controls="controls" src="https://www.youtube.com/embed/m_vv2s5Trn4"></iframe>
      
Instead of specifying the video reference using the @data attribute you can also specify it using a parameter like:
  <param name="src" value="clips/Clip_480_5sec_6mbps_h264.mp4"/>
All other parameter elements specified on the DITA <object> are set as attributes on the generated HTML 5 element. 
  
When producing the PDF output, the DITA <object> elements which have @outputclass audio/video or iframe are output as links.

The plugin was updated to also produce similar results from Lightweight DITA <audio> and <video> elements.
For example:
 1. The Lightweight DITA structure:
            <audio>
             <controls/>
             <source value="Sleep Away.mp3" />
            </audio>

        is converted to:
        
        <audio controls="controls"><source src="Sleep Away.mp3"></source></audio>
        
 2. The Lightweight DITA structure:
           <video>
            <controls/>
            <source value="Clip_480_5sec_6mbps_h264.mp4" />
           </video>

      is converted to:
      
      <video controls="controls"><source src="Clip_480_5sec_6mbps_h264.mp4"></source></video>
      
3. The Lightweight DITA structure:
 
          <video>
           <controls/>
           <source value="https://www.youtube.com/embed/m_vv2s5Trn4"/>
          </video>

      is converted to:
      
      <iframe controls="controls" src="https://www.youtube.com/embed/m_vv2s5Trn4"></iframe>

If for a certain HTML type output (for example CHM) you want to add a plain link to the video instead of embedding it, there is a parameter called "com.oxygenxml.xhtml.linkToMediaResources" which can be set to "true".
