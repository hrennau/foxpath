module namespace const="http://www.parsqube.de/xspy/constants";

declare variable $const:TSUMMARY_LABELS := 'base bbase co aeg ki sgh sgm use' ! tokenize(.);
declare variable $const:URI_XSD := 'http://www.w3.org/2001/XMLSchema';
declare variable $const:URI_XSPY := 'http://www.parsqube.de/xspy/structure';
declare variable $const:URI_NETEX := 'http://www.netex.org.uk/netex';

declare variable $const:PTYPE_WHITELIST := ();
declare variable $const:PTYPE_BLACKLIST := '*_VersionStructure';

declare variable $const:DEBUG_LEVEL := 0;

declare variable $const:REL_PATH_NETEX := '../../../NeTEx-CEN';
declare variable $const:PATH_PUBLICATION_DELIVERY := 'xsd/NeTEx_publication.xsd';
declare variable $const:FNAME_PUBLICATION_DELIVERY_GENERATED := 'NeTEx_publication.genkeyref.xsd';

declare variable $const:SUPPRESS_FIELD_ORDER as xs:boolean := true();
declare variable $const:SUPPRESS_DEEP_KEY_IF_DERIVED_SKIPPED_EXISTS as xs:boolean := false();
