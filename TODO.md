* Logging for verbose mode
* Improved error handling
* Sinatra interface
* $SAFE = 4 for erb content or treetop DSL, if $SAFE = 4 out of reach

#### CSS guidance for printing
- style for screen 
- print media to correct for paper
- pagination
    page-break-after:always;
    page-break-before:always;
    page-break-after:avoid;
    page-break-before:avoid;
- serif font
    body {
    	font-family: Georgia, "Times New Roman", 
      background-color: transparent;
      color: black; 
    	Times, serif;
    	font-size: 12pt;
    	line-height: 18pt;
    }
- size and borders and margins
    body #container {
    	margin: 1in 1.2in .5in 1.2in;
    } 
    @page { margin: 0.5cm; }
- display link hrefs
    a:after, a:link:after  { 
    color: #000000;
    background-color:transparent; 
    content: " * Link " attr(href) "* "; }

    a:visited:after {
    color:#000000; 
    background-color:transparent;
    content: " * Link " attr(href) "* "; }
    
    #main p a:after {
    	content: " ("attr(href)") ";
    	font-size: 10pt;
    }

- lessons from boilerplate
    @media print {
      * { background: transparent !important; color: black !important; text-shadow: none !important; filter:none !important; -ms-filter: none !important; } /* Black prints faster: h5bp.com/s */
      a, a:visited { text-decoration: underline; }
      a[href]:after { content: " (" attr(href) ")"; }
      abbr[title]:after { content: " (" attr(title) ")"; }
      .ir a:after, a[href^="javascript:"]:after, a[href^="#"]:after { content: ""; }  /* Don't show links for images, or javascript/internal links */
      pre, blockquote { border: 1px solid #999; page-break-inside: avoid; }
      thead { display: table-header-group; } /* h5bp.com/t */
      tr, img { page-break-inside: avoid; }
      img { max-width: 100% !important; }
      @page { margin: 0.5cm; }
      p, h2, h3 { orphans: 3; widows: 3; }
      h2, h3 { page-break-after: avoid; }
    }
