latex input:		mmd-article-header
Title:			ANT298 HW#1	
Author:				Noam Ross
Date:				January 17, 2012 
Base Header Level:	1
LaTeX Mode:			memoir  
latex input:		mmd-article-begin-doc
latex input:		mmd-natbib-plain
latex footer:		mmd-memoir-footer
HTML header: <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"> </script>

<!--roptions dev=png,fig.width=5,fig.height=5,cache=FALSE, fig.show=asis-->
<!-- begin.rcode captionhook, echo=FALSE, results='hide'
  knit_hooks$set(plot = function(x,options) {
      base = opts_knit$get('base.url')
      if (is.null(base)) base = ''
      caption = opts_knit$get('caption')
      if (is.null(caption)) caption = options$label
      sprintf('![%s](%s%s.%s)', options$caption,
              base, x[1], x[2])
  })
  end.rcode -->

# Start up #

<!-- begin.rcode load
  require(stratigraph)
  require(gdata)
  require(xtable)
  require(knitr)
  end.rcode -->
  
