#include <string.h>
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLparser.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libexslt/exslt.h>



extern int xmlLoadExtDtdDefaultValue;

static void usage(const char *name) {
    printf("Usage: %s [options] stylesheet file [file ...]\n", name);
    printf("      --param name value : pass a (parameter,value) pair\n");

}

int
main(int argc, char **argv) {

  printf ("has xml include: %d",xmlHasFeature(XML_WITH_XINCLUDE));
  int i;
  const char *params[16 + 1];
  int nbparams = 0;
  xsltStylesheetPtr cur = NULL;
  htmlDocPtr doc, res;

  if (argc <= 1) {
    usage(argv[0]);
    return(1);
  }
  

 for (i = 1; i < argc; i++) {
        if (argv[i][0] != '-')
            break;
  if ((!strcmp(argv[i], "-param")) ||
                   (!strcmp(argv[i], "--param"))) {
    i++;
    params[nbparams++] = argv[i++];
    params[nbparams++] = argv[i];
    if (nbparams >= 16) {
      fprintf(stderr, "too many params\n");
      return (1);
    }
        }  else {
            fprintf(stderr, "Unknown option %s\n", argv[i]);
            usage(argv[0]);
            return (1);
        }
    }

  exsltRegisterAll();
  params[nbparams] = NULL;
  xmlSubstituteEntitiesDefault(1);
  xmlLoadExtDtdDefaultValue = 1;

  xmlDocPtr stylesheetDoc = xmlReadFile(argv[i], NULL, XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_XINCLUDE);
  xmlXIncludeProcess(stylesheetDoc);
  cur = xsltParseStylesheetDoc(stylesheetDoc);

  //cur = xsltParseStylesheetFile((const xmlChar *)argv[i]);
  i++;
  doc = htmlParseFile(argv[i],NULL);
  res = xsltApplyStylesheet(cur, doc, params);
  xsltSaveResultToFile(stdout, res, cur);

  xsltFreeStylesheet(cur);
  xmlFreeDoc(res);
  xmlFreeDoc(doc);

        xsltCleanupGlobals();
        xmlCleanupParser();
  return(0);

}