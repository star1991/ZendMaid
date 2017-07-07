// from http://datatables.net/plug-ins/sorting
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "num-html-pre": function ( a ) {
        var x = String(a).replace( /<[\s\S]*?>/g, "" );
        return parseFloat( x );
    },

    "num-html-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "num-html-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );

// from http://datatables.net/plug-ins/type-detection
jQuery.fn.dataTableExt.aTypes.unshift( function ( sData )
{
    sData = typeof sData.replace == 'function' ?
        sData.replace( /<[\s\S]*?>/g, "" ) : sData;
    sData = $.trim(sData);

    var sValidFirstChars = "0123456789-";
    var sValidChars = "0123456789.";
    var Char;
    var bDecimal = false;

    /* Check for a valid first char (no period and allow negatives) */
    Char = sData.charAt(0);
    if (sValidFirstChars.indexOf(Char) == -1)
    {
        return null;
    }

    /* Check all the other characters are valid */
    for ( var i=1 ; i<sData.length ; i++ )
    {
        Char = sData.charAt(i);
        if (sValidChars.indexOf(Char) == -1)
        {
            return null;
        }

        /* Only allowed one decimal place... */
        if ( Char == "." )
        {
            if ( bDecimal )
            {
                return null;
            }
            bDecimal = true;
        }
    }

    return 'num-html';
} );
