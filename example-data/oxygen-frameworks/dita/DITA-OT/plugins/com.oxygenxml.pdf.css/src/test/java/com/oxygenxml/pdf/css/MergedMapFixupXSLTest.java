/*
 *  The Syncro Soft SRL License
 *
 *  Copyright (c) 1998-2012 Syncro Soft SRL, Romania.  All rights
 *  reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistribution of source or in binary form is allowed only with
 *  the prior written permission of Syncro Soft SRL.
 *
 *  2. Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *
 *  3. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in
 *  the documentation and/or other materials provided with the
 *  distribution.
 *
 *  4. The end-user documentation included with the redistribution,
 *  if any, must include the following acknowledgment:
 *  "This product includes software developed by the
 *  Syncro Soft SRL (http://www.sync.ro/)."
 *  Alternately, this acknowledgment may appear in the software itself,
 *  if and wherever such third-party acknowledgments normally appear.
 *
 *  5. The names "Oxygen" and "Syncro Soft SRL" must
 *  not be used to endorse or promote products derived from this
 *  software without prior written permission. For written
 *  permission, please contact support@oxygenxml.com.
 *
 *  6. Products derived from this software may not be called "Oxygen",
 *  nor may "Oxygen" appear in their name, without prior written
 *  permission of the Syncro Soft SRL.
 *
 *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
 *  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 *  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 *  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 */
package com.oxygenxml.pdf.css;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.Reader;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import junit.framework.TestCase;

import org.apache.log4j.Logger;

import ro.sync.basic.utilities.IOUtil;
import ro.sync.basic.utilities.PrettyPrintException;
import ro.sync.basic.utilities.PrettyPrinter;

/**
 * Tests the /eXml/frameworks/dita/DITA-OT/plugins/com.oxygenxml.pdf.prince/post-process.xsl stylesheet.
 * 
 * @author dan
 *
 */
public class MergedMapFixupXSLTest extends TestCase {

  /**
   * Constructor.
   * 
   * @param name
   * @throws TransformerFactoryConfigurationError 
   * @throws TransformerConfigurationException 
   */
  public MergedMapFixupXSLTest(String name) throws TransformerConfigurationException, TransformerFactoryConfigurationError {
    super(name);
   
  }

  /**
   * Logger for logging.
   */
  private static final Logger logger = Logger.getLogger(MergedMapFixupXSLTest.class
      .getName());

  /**
   *  Infer some parameters from it. Used to create absolute paths to the images.
   */
  private File mapFile = new File("test/dita/samples/flowers/flowers.ditamap");

  private File dir = new File("test");


  @Override
  public void setUp() throws Exception {
    super.setUp();
  }
  
  @Override
  public void tearDown() throws Exception {
    super.tearDown();
  }
  
  /**
   * Runs the test by loading the test class into the Oxygen
   * LateDelegationClassloader.
   * 
   * @param testMethod The name of the method to be run.
   * @param additionalCLUrl Additional URLs to be loaded by class loader.
   * @throws Exception when it fails.
   */
  @SuppressWarnings({ "rawtypes", "unchecked" })
  protected void runTestInURLClassLoader(String testMethod, URL[] urls) throws Exception{
    if(logger.isDebugEnabled()){
      logger.debug("Running in oXygen class loader method: " + testMethod);
    }
    
    Thread cThread = Thread.currentThread();
    // Get system properties to be restored
    Properties systemProp = System.getProperties();
    Properties toRestore = new Properties();
    for (Iterator iter = systemProp.keySet().iterator(); iter.hasNext();) {
      Object key = iter.next();
      toRestore.put(key, systemProp.get(key));
    }
    // Use SAXParserFactory from Xerces 
    System.setProperty(
        "javax.xml.parsers.SAXParserFactory", 
        "org.apache.xerces.jaxp.SAXParserFactoryImpl");
    
    ClassLoader oldCL = cThread.getContextClassLoader();
    
    if(logger.isDebugEnabled()){
      logger.debug("The old class loader: " + oldCL);
    }
        


    // Optimization. Avoid loading the same jars in multiple class loaders.
    // Was: ClassLoader classLoader = new LateDelegationClassLoader(urls);
    ClassLoader classLoader = new URLClassLoader(urls, 
        this.getClass().getClassLoader());    
    if(logger.isDebugEnabled()){
      logger.debug("Using the classloader " + classLoader);
    }
    
    cThread.setContextClassLoader(classLoader);
    
    
    try {
      Class cl = classLoader.loadClass(this.getClass().getName());
      Object obj = cl.getConstructor(new Class[]{String.class}).newInstance(new Object[]{"test"});
      
      // Run setUp
      Method m = cl.getMethod("setUp", new Class[]{});
      m.invoke(obj, new Object[]{});
      try{
        // The test
        m = cl.getMethod(testMethod, new Class[]{});
        m.invoke(obj, new Object[]{});
      }catch(InvocationTargetException ex){
        Throwable cause = ex.getCause();
        if(cause instanceof Exception){
          throw (Exception) cause;
        } else if(cause instanceof Error){
          throw (Error) cause;
        } else {
          throw ex;
        }
      }finally{
        // End.
        m = cl.getMethod("tearDown", new Class[]{});
        m.invoke(obj, new Object[]{});        
      }
    } finally {
      cThread.setContextClassLoader(oldCL);
      // Restore system properties
      System.setProperties(toRestore);
    }      
  }
  
  /**
   * <p><b>Description:</b> DESCRIBE THE TEST HERE!!</p>
   * <p><b>Bug ID:</b> EXM-</p>
   *
   * @author dan
   *
   * @throws Exception
   */
  public void testProcessing() throws Exception {
    runTestInURLClassLoader("tProcessing", new URL[] {new File("xsl/java").toURI().toURL()});    
  }
  
  /**
   * The real test. It is run in the Oxygen class loader, because we use saxon:parse extension function, and
   * this requires the Saxon EE, (or a version less than 9 as is used from DITA-OT) .
   * 
   * @throws Exception
   */
  public void tProcessing() throws Exception {
    
    TransformerFactory transformerFactory = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", getClass().getClassLoader()); 
    
    File style = new File("xsl/post-process.xsl");
    File styleReviewReplies = new File("xsl/review/review-group-replies.xsl");

    String[] list = dir.list(new FilenameFilter() {
      @Override
      public boolean accept(File dir, String name) {
        return name.endsWith(".in.xml");
      }
    });
    
    
    for (String path : list) {
      
      File inputFile = new File(dir, path).getAbsoluteFile();
      File expectFile = new File(inputFile.getAbsolutePath().replace(".in.xml", ".out.xml"));
      File ppDisableFile = new File(inputFile.getAbsolutePath().replace(".in.xml", ".out.no.pp"));

//    if (!path.startsWith("dita.flagging")) { 
//     continue;
//    }
      
      logger.info("------------------------" );
      logger.info("Asserting " + path);
      logger.info("Input    " + inputFile);
      logger.info("Expected " + expectFile);

      // Stage 1.
      Transformer transformer = transformerFactory.newTransformer(new StreamSource(style));      
      setUpParameters(transformer, inputFile, mapFile);
      
      String string = IOUtil.readFile(inputFile, "UTF-8");
      
      string = string.replace("MAP_FILE_DIR", mapFile.getParentFile().getAbsolutePath());
      
      Reader reader = new StringReader(string);
      
      Source xmlSource = new StreamSource(reader);
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      StreamResult outputTarget = new StreamResult(bos);
      transformer.transform(xmlSource, outputTarget);
      bos.close();
      
      String intermediate = new String(bos.toByteArray(), "UTF-8");
      
      // Stage 2: Structuring the oxy:oxy-comment as a discussion thread. 
      Transformer transformer2 = transformerFactory.newTransformer(new StreamSource(styleReviewReplies));
      xmlSource = new StreamSource(new ByteArrayInputStream(bos.toByteArray()));      
      bos = new ByteArrayOutputStream();
      outputTarget = new StreamResult(bos);
      transformer2.transform(xmlSource, outputTarget);
      

      String expected = filter(IOUtil.readFile(expectFile, "UTF-8"), path, true, ppDisableFile.exists());
      String obtained = filter(new String(bos.toByteArray(), "UTF-8"), path, false, ppDisableFile.exists());
      obtained = remapIDs(obtained);

      boolean doNotFailUpdateTests = false;

      if (doNotFailUpdateTests) {
        FileOutputStream fos = new FileOutputStream(expectFile);
        fos.write(obtained.getBytes("UTF-8"));
        fos.close();
      }
      
      if (!doNotFailUpdateTests && !expected.equals(obtained)){
        // Dump the obtained.
        logger.info("Obtained \n" + obtained);
        logger.info("Intermediate was \n" + intermediate);
        assertEquals("The stylesheet changed behaviour. Failed in " + inputFile.getName(), expected, obtained);          
      }
      
      
      logger.info("Ok.");
      logger.info("------------------------" );

    }
  }



  /**
   * Map the random XSLT generated IDs to foreseeable sequential numbers. 
   * We need to decouple them because the Linux and Windows XSLT transformation generate different IDs,
   * and we need to have fix values in the assertion "expected" values.  
   *  
   * @param obtained The content of the merged document, as it comes processed by the plugin.
   *
   * @return The content, with changed IDs.
   */
  private String remapIDs(String obtained) {
    
    
    // Identify all the unique IDs from the XML source
    LinkedHashMap<String, Integer> ids = new LinkedHashMap<String, Integer>();
    
    Pattern idPattern = Pattern.compile("[\"|#|\\[]d([A-Fa-f0-9]*?)[\"|\\]]");
    int cnt = 0;
    Matcher matcher = idPattern.matcher(obtained);
    while(matcher.find()) {
      
      
     String idInSource = matcher.group(1);
     if (!ids.containsKey(idInSource)) {
       // An unknown ID, let's assign it a sequence number.
       cnt ++;
       ids.put(idInSource, cnt);
     }     
    }

    // Now replace all the IDs by the sequence number.
    Set<String> keySet = ids.keySet();
    for (String key : keySet) {
      obtained = obtained.replace("d" + key, "remapped_id_" + ids.get(key));      
    }
    
    return obtained;
  }

  /**
   * Gives a chance of setting parameters to the transformer. You can 
   * use this to also set different parameters depending on the input file.
   * 
   * @param transformer The trasformer to set up parameters on.
   * @param inputFile The input file of the XSLT tranformation. 
   * @param mapFile The main map file. 
   * @throws MalformedURLException Should not happen.
   */
  private void setUpParameters(Transformer transformer, File inputFile, File mapFile) throws MalformedURLException {
    transformer.setParameter("input.dir.url", mapFile.getParentFile().toURI().toURL().toString() + "/");
    transformer.setParameter("show.changes.and.comments", "yes");
    
    if (inputFile.getName().startsWith("args.draft.yes")){      
      transformer.setParameter("args.draft", "yes");
    }    
  }

  /**
   * Filters some whitespaces, so the asserts are more reliable.
   * @param in The string to be filtered.
   * @param isExpectedString <code>true</code> if the <code>in</code> parameter 
   *  is the expected string. Otherwise, is a XSLT result and further processing 
   *  can be performed, in order to change variable parts to fixed (generated IDs, 
   *  paths, etc..) that otherwise could not be asserted.
   * @param disablePrettyPrint <code>true</code> if the PP should be disabled.
   * @return
   * @throws Exception 
   * @throws PrettyPrintException 
   */
  private String filter(String in, String path, boolean isExpectedString, boolean disablePrettyPrint) throws Exception {
    
    if (!isExpectedString){
      if ("images.in.xml".equals(path)){
        in = in.replaceAll("file\\:/(.*?)/" + mapFile.getParentFile().getName(), "MAP_DIR_URI");
      }
    }
    
    String out;
    in = in.replace("\r", "");
    
    if (disablePrettyPrint) {
      out = in;
    } else {
      out = PrettyPrinter.prettyPrint(in).replaceAll("\r", "").trim();
    }
    System.out.println("Pretty printed: " + out);
    
    return out;
  }

  

  /**
   * <p><b>Description:</b> Testcase for the performance of the post processing.</p>
   * <p><b>Bug ID:</b> CH-205</p>
   *
   * @author dan
   *
   * @throws Exception
   */
  public void testUserGuideTransformTime() throws Exception {
    runTestInURLClassLoader("tUserGuideTransformTime", new URL[] {new File("xsl/java").toURI().toURL()});    
  }
  

  /**
   * The real test, run in the Oxygen class loader.
   * 
   * @throws Exception
   */
  public void tUserGuideTransformTime() throws Exception{

    TransformerFactory transformerFactory = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", getClass().getClassLoader()); 
    
    File style = new File("xsl/post-process.xsl");
    File inputFile = new File(dir, "large-file/file.in.xml").getAbsoluteFile();
    File outputFile = new File(dir, "large-file/file.out.xml").getAbsoluteFile();
    outputFile.delete();
    
    Transformer transformer = transformerFactory.newTransformer(new StreamSource(style));      
    setUpParameters(transformer, inputFile, new File("large-file/file.ditamap"));
    
    Source xmlSource = new StreamSource(inputFile);
        
    StreamResult outputTarget = new StreamResult(outputFile);
    
    logger.info("Starting transformation.");    

    long t0 = System.currentTimeMillis();
    transformer.transform(xmlSource, outputTarget);
    long t1 = System.currentTimeMillis();    
    long delta = t1 - t0;
    
    logger.info("Ending transformation after: " + delta + "ms ");    
    assertTrue ("Transformation took too long: "  + delta + "ms ", delta < 60000);
    
    String content = IOUtil.readFile(outputFile, "UTF-8");
    assertTrue("There should be highling elements ", content.contains("<oxy:oxy-color-hl"));
    assertTrue("There should be comment elements ", content.contains("<oxy:oxy-comment"));
    assertTrue("There should be insert elements ", content.contains("<oxy:oxy-insert"));
    assertTrue(outputFile.delete());
  }   
}
