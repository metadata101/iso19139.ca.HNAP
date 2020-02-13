/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
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

import java.io.File;
import java.net.URI;
import java.nio.file.Paths;
import java.util.*;
import org.apache.commons.lang.StringUtils;
import org.apache.tools.ant.util.DateUtils;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;
import org.fao.geonet.util.XslUtil;

import javax.annotation.Nonnull;

public class XslUtilHnap {
    //TODO, change to 'iso19139.hnap' after schema is renamed. Task 19337
    final private static String HNAP_SCHEMA_NAME = "iso19139.nap";
    private static String strSchemaDir = null;


    /**
     * Compares dates (used for temporal extent dates comparison),
     * managing the different formats allowed: yyyy-mm-dd, yyyy-mm, yyyy.
     * ported from utils-fn.xsl in ec
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
     * From df-build\XslUtil.java, declared in utils-fn.xsl, used in napec schematron .sch files
     * ported from utils-fn.xsl in ec
     * @param date
     * @return
     */
    public static int verifyDateFormat(String date) {
        Log.debug(Geonet.SCHEMA_MANAGER, "verifyDateFormat extension is called to verify date format : " + date);

        if (StringUtils.isEmpty(date)) return 1;

        if (date.length() == 4) {
            try {
                int yearValue = Integer.parseInt(date);

                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date + "-01-01");

                return 1;
            } catch (Exception ex) {
                return 0;
            }
        } else if (date.length() == 7) {

            try {
                int yearValue = Integer.parseInt(date.substring(0, 4));
                int monthValue = Integer.parseInt(date.substring(5, 7));

                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date + "-01");

                return 1;
            } catch (Exception ex) {
                return 0;
            }
        } else if (date.length() == 10) {
            try {
                int yearValue = Integer.parseInt(date.substring(0, 4));
                int monthValue = Integer.parseInt(date.substring(5, 7));
                int dayValue = Integer.parseInt(date.substring(8, 10));

                Date dateValue = DateUtils.parseIso8601DateTimeOrDate(date);

                return 1;
            } catch (Exception ex) {
                return 0;
            }

        } else {
            return 0;
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
     * @param iso3LangCode The 2 iso lang code
     * @return The related 3 iso lang code
     */
    public static
    @Nonnull
    String twoCharLangCode(String iso3LangCode, String defaultValue) {
        if (iso3LangCode.contains(";")) {
            //DFO BY - DEBUG - form-builder.xsl calls this function at line 238
            //Log.debug(Geonet.SCHEMA_MANAGER, "XslUtilHnap::iso3LangCode : " + iso3LangCode + " is trimmed to : " + iso3LangCode.substring(0, iso3LangCode.indexOf(";")));
            iso3LangCode = iso3LangCode.substring(0, iso3LangCode.indexOf(";"));
        }
        return XslUtil.twoCharLangCode(iso3LangCode, defaultValue);
    }

    /**
     * This helper is used in update-fixed-info to get the 3 char lang code from hnap lang code
     * @param hnapLangCode  hnap lang code, e.g. eng; CAN
     * @param defaultValue
     * @return
     */
    public static
    @Nonnull
    String toIso3LangCode(String hnapLangCode, String defaultValue) {
        if (hnapLangCode != null && !hnapLangCode.isEmpty()) {
            if (hnapLangCode.contains(";")) {
                return hnapLangCode.substring(0, hnapLangCode.indexOf(";"));
            }
            return hnapLangCode;
        }
        return defaultValue;
    }

    /**
     * These two functions map {"eng; CAN":"#", "fra":"fra"} to '{"eng":"#eng; CAN", "fre" : "#fra"}' in utility-tpl-multilingual.xsl
     *
     * @param lang  hnap language code
     * @return  iso639 language code
     */
    public static
    @Nonnull
    String getMappedLang(String lang) {
        switch(lang) {
            case "eng; CAN":
                return "eng";

            case "fra":
            case "fra; CAN":
                return "fre";

            default:
                return lang;
        }
    }

    /**
     * Substitute id with lang if id is absent
     * @param lang
     * @param id
     * @return
     */
    public static
    @Nonnull String getMappLangId(String lang, String id) {
        if (id == null || id.isEmpty()) {
            return lang;
        }
        else {
            return id;
        }
    }

    /**
     * Get thesauriDir from system config value
     * @return Code list folder path. i.e. C:\dev\src\geonetwork-catalog\web\target\geonetwork\WEB-INF\data\config\codelist
     */
    public static
    @Nonnull
    String getThesauriDir() {
        String result = XslUtil.getConfigValue(Geonet.Config.CODELIST_DIR);
        return result;
    }

    /*
     * Calculate schemaDir from system config value. i.e. C:\dev\src\geonetwork-catalog\web\target\geonetwork\WEB-INF\data\config\schema_plugins\iso19139.nap
     * @return The schema folder path
     */
    public static
    @Nonnull
    String getSchemaDir() {
        if (strSchemaDir == null) {
            strSchemaDir = XslUtil.getConfigValue(Geonet.Config.SCHEMAPLUGINS_DIR) + File.separator + HNAP_SCHEMA_NAME;
        }
        return strSchemaDir;
    }

    /*
     * Calculate codeList file path from language code
     * @param langCode  Language code, eng or fre
     * @return The code list file path
     * Example : C:\dev\src\geonetwork-catalog\web\target\geonetwork\WEB-INF\data\config\schema_plugins\iso19139.nap\loc\eng\codelists.xml
     */
    public static
    @Nonnull
    String getCodeListFileUri(String langCode) {
        if (!langCode.equals("eng") && !langCode.equals("fre")) {
            langCode = "eng";
        }

        URI result = Paths.get(getSchemaDir(), "loc", langCode, "codelists.xml").toUri();
        return result.toString();
    }
}
