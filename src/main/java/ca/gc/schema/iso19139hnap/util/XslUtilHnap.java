/*
 * Copyright (C) 2001-2021 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

/*
 * ISO19139.hnap xsl utilities
 * Ported from XslUtil.java and utils-fn.xsl in ecc geonetwork
 */

package ca.gc.schema.iso19139hnap.util;


import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceExtent;
import org.apache.commons.lang.StringUtils;
import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URIBuilder;
import org.apache.tools.ant.util.DateUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.util.XslUtil;
import org.fao.geonet.utils.Log;

import javax.annotation.Nonnull;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class XslUtilHnap {
    //TODO, change to 'iso19139.hnap' after schema is renamed. Task 19337
    final private static String HNAP_SCHEMA_NAME = "iso19139.ca.HNAP";
    private static String strSchemaDir = null;


    /**
     * Compares dates (used for temporal extent dates comparison),
     * managing the different formats allowed: yyyy-mm-dd, yyyy-mm, yyyy.
     * ported from utils-fn.xsl in ec
     *
     * @param endDate
     * @param startDate
     * @return
     */
    public static int compareDates(String endDate, String startDate) {
        Log.debug(Geonet.SCHEMA_MANAGER, "compareDates extension is called to compare : " + endDate + ", " + startDate);
        if (StringUtils.isEmpty(endDate) || StringUtils.isEmpty(startDate)) {
            return 1;
        } else {
            try {

                endDate = calculateDate(endDate, false);
                startDate = calculateDate(startDate, true);

                Date date1Value = DateUtils.parseIso8601DateTimeOrDate(endDate);
                Date date2Value = DateUtils.parseIso8601DateTimeOrDate(startDate);

                return date1Value.compareTo(date2Value);

            } catch (Exception ex) {
                return 1;
            }
        }
    }

    private static String calculateDate(String dateVal, boolean startDate) throws Exception {
        if (dateVal.length() == 4) {
            if (startDate) {
                dateVal = dateVal + "-01-01T00:00:00Z";
            } else {
                dateVal = dateVal + "-12-31T23:59:59Z";
            }
        } else if (dateVal.length() == 7) {
            if (startDate) {
                dateVal = dateVal + "-01T00:00:00Z";
            } else {
                dateVal = dateVal + "-01T23:59:59Z";

                Date date1Value = DateUtils.parseIso8601DateTimeOrDate(dateVal);

                // Last day of the month
                Calendar c = Calendar.getInstance();
                c.setTime(date1Value);
                c.set(Calendar.DAY_OF_MONTH, c.getActualMaximum(Calendar.DAY_OF_MONTH));

                dateVal = c.get(Calendar.YEAR) + "-" + (c.get(Calendar.MONTH) + 1) + "-" + c.get(Calendar.DAY_OF_MONTH) + "T23:59:59Z";
            }
        } else if (dateVal.length() == 10) {
            if (startDate) {
                dateVal = dateVal + "T00:00:0Z";
            } else {
                dateVal = dateVal + "T23:59:59Z";
            }
        }

        return dateVal;

    }

    /**
     * From df-build\XslUtil.java, declared in utils-fn.xsl, used in schematron .sch files
     * ported from utils-fn.xsl in ec
     *
     * @param date
     * @return
     */
    public static int verifyDateFormat(String date) {
        Log.debug(Geonet.SCHEMA_MANAGER, "verifyDateFormat extension is called to verify date format : " + date);

        if (StringUtils.isEmpty(date)) return 1;

        if (date.length() == 4) {
            try {
                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date + "-01-01");

                return 1;
            } catch (Exception ex) {
                return 0;
            }
        } else if (date.length() == 7) {
            try {
                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date + "-01");

                return 1;
            } catch (Exception ex) {
                return 0;
            }
        } else {
            try {
                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date);

                return 1;
            } catch (Exception ex) {
                return 0;
            }

        }
    }

    /**
     * Return 2 iso lang code from a 3 iso lang code. If any error occurs return "".
     *
     * @param iso3LangCode The 2 iso lang code
     * @return The related 3 iso lang code
     */
    public static
    @Nonnull
    String twoCharLangCode(String iso3LangCode) {
        return XslUtilHnap.twoCharLangCode(iso3LangCode, XslUtil.twoCharLangCode(Geonet.DEFAULT_LANGUAGE, null));
    }

    /**
     * Return 2 iso lang code from a 3 iso lang code. If any error occurs return "".
     *
     * @param iso3LangCode The 2 iso lang code
     * @return The related 3 iso lang code
     */
    public static
    @Nonnull
    String twoCharLangCode(String iso3LangCode, String defaultValue) {
        if (iso3LangCode.contains(";")) {
            //Log.debug(Geonet.SCHEMA_MANAGER, "XslUtilHnap::iso3LangCode : " + iso3LangCode + " is trimmed to : " + iso3LangCode.substring(0, iso3LangCode.indexOf(";")));
            iso3LangCode = iso3LangCode.substring(0, iso3LangCode.indexOf(";"));
        }
        return XslUtil.twoCharLangCode(iso3LangCode, defaultValue);
    }

    /**
     * Get thesauriDir from system config value
     *
     * @return Code list folder path. i.e. WEB-INF\data\config\codelist
     */
    public static
    @Nonnull
    String getThesauriDir() {
        String result = XslUtil.getConfigValue(Geonet.Config.CODELIST_DIR);
        return result;
    }

    /**
     * Given a String representing a URL and a query parameter name return the value of the requested parameter.
     * Search is case-insensitive.
     *
     * @param paramName the name of the parameter.
     * @param url       a string representing a URL.
     * @return the value of the parameter. If {@code}paramName{@code} is not a valid URL or a parameter with the passed
     * name doesn't exist return an empty string. If there is more than one parameter with the same name return their
     * values separated by the "," sign.
     */
    public static @Nonnull
    String extractUrlParameter(String paramName, String url) {
        final List<NameValuePair> queryParams;
        String result = "";
        try {
            queryParams = new URIBuilder(url).getQueryParams();
            List<String> foundValues = queryParams.stream().filter(nvp -> nvp.getName().equalsIgnoreCase(paramName))
                .map(NameValuePair::getValue).collect(Collectors.toList());
            result = foundValues.stream().filter(StringUtils::isNotEmpty).collect(Collectors.joining(","));
        } catch (URISyntaxException e) {
            Log.info(Geonet.SCHEMA_MANAGER, "cannot parse URL in extractUrlParameter method. url=" + url);
        }


        return result;
    }

    /**
     * Remove the parameters passed from the URL query.
     *
     * @param parametersToRemove an ArrayList with NodeInfo which values are the parameters name to remove from the URL.
     * @param url                a String representing a URL.
     * @return the url passed without the specified parameters in the query. If url is not a valid URL then return the
     * empty string.
     */
    public static @Nonnull
    String removeFromUrl(ArrayList<NodeInfo> parametersToRemove, String url) {
        // Note: don't generalize the ArrayList to a List. Saxon needs a concrete class here. It can't instantiate an
        // interface.
        String result = "";
        try {
            URIBuilder builder = new URIBuilder(url);
            List<NameValuePair> queryParams = builder.getQueryParams();
            List<NameValuePair> newQueryParams = queryParams.stream().filter(nameValuePair ->
                parametersToRemove.stream().noneMatch(
                    paramToRemove -> nameValuePair.getName().equalsIgnoreCase(paramToRemove.getStringValue()))
            ).collect(Collectors.toList());
            builder.setParameters(newQueryParams);
            result = builder.build().toString();


        } catch (URISyntaxException e) {
            Log.info(Geonet.SCHEMA_MANAGER, "cannot parse URL in removeFromUrl method. url=" + url);
            result = url;
        }

        return result;
    }

    /**
     * Validate if email format. Empty email is allowed based on parameter of allowEmptyEmail.
     * See more info: https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
     * @param emailAddress email address to validate the pattern
     * @param allowEmptyEmail allow empty email input. The empty email was handled within the schematron already. This flag allows to ignore repeat checking.
     * @return boolean
     */
    public static boolean isEmailFormat(String emailAddress, boolean allowEmptyEmail) {
        if (allowEmptyEmail && org.apache.commons.lang3.StringUtils.isEmpty(emailAddress)) {
            return true;
        }

        Pattern pattern = Pattern.compile("^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
        Matcher matcher = pattern.matcher(emailAddress);
        return matcher.matches();
    }

    /**
     * Check if there is duplicated online resource with the same url+name combinations.
     *
     * @param onlineResources gmd:transferOptions/../gmd:onLine sequence
     * @return boolean flag is no duplication found
     * @throws XPathException
     */
    public static boolean hasNoDuplicatedOnlineResource (Object onlineResources) throws XPathException {
        boolean hasNoDuplication = true;
        if (onlineResources instanceof SequenceExtent) {
            SequenceExtent sequence = (SequenceExtent) onlineResources;
            SequenceIterator iterator = sequence.iterate();
            List<String> onlineResoucesNameUrlList = new ArrayList<>();
            Set<String> onlineResoucesNameUrlSet = new HashSet<>();
            while (true) {
                Item item = iterator.next();

                if (item == null) {
                    break;
                }
                String[] info = item.getStringValue().trim().replace(" ","").split("\n");
                String url = info[0];
                String name = info[2];
                onlineResoucesNameUrlList.add(name+url);
                onlineResoucesNameUrlSet.add(name+url);
            }

            // Compare the list and set. The set does not allow duplications.
            hasNoDuplication = onlineResoucesNameUrlList.size() == onlineResoucesNameUrlSet.size();
        }

        return hasNoDuplication;
    }
}
