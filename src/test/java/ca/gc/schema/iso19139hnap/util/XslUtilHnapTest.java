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
package ca.gc.schema.iso19139hnap.util;

import net.sf.saxon.event.Receiver;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.tinytree.TinyNodeImpl;
import net.sf.saxon.trans.XPathException;
import org.junit.Test;

import java.util.ArrayList;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests for {@link XslUtilHnap} class.
 */
public class XslUtilHnapTest {

    @Test
    public void extractUrlParameter() {
        String testUrl = "http://www.example.com/my/path?parameter1=value1&parameter2=value2&emptyParam="
            + "&parameter3=value3&parameterSeparatedByComma=value41,value42&multipleParameter=multipleParameterValue1"
            + "&multipleParameter=multipleParameterValue2&pArAmEtErCaSeInSeNsItIvE=value";

        String actualResult = XslUtilHnap.extractUrlParameter("parameter1", testUrl);
        assertEquals("parameter1", "value1", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("parameter2", testUrl);
        assertEquals("parameter2", "value2", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("parameter3", testUrl);
        assertEquals("parameter3", "value3", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("parameterSeparatedByComma", testUrl);
        assertEquals("parameterSeparatedByComma", "value41,value42", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("multipleParameter", testUrl);
        assertEquals("multipleParameter", "multipleParameterValue1,multipleParameterValue2", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("nonExistingParam", testUrl);
        assertEquals("nonExistingParam", "", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("emptyParam", testUrl);
        assertEquals("emptyParam", "", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("abc", " malformed url");
        assertEquals("malformed url", "", actualResult);

        actualResult = XslUtilHnap.extractUrlParameter("parametercaseinsensitive", testUrl);
        assertEquals("test case insensitive", "value", actualResult);

    }

    @Test
    public void removeFromUrl() {
        String testUrl = "http://www.example.com/my/path?parameter1=value1&parameter2=value2&emptyParam=&"
            + "parameter3=value3&parameterSeparatedByComma=value41,value42&multipleParameter=multipleParameterValue1"
            + "&multipleParameter=multipleParameterValue2&pArAmEtErCaSeInSeNsItIvE=value";
        NodeInfo param = new MyTinyNodeImpl("parameter1");
        ArrayList<NodeInfo> paramsToRemove = new ArrayList<>();
        paramsToRemove.add(param);
        String actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("parameter1", "http://www.example.com/my/path?parameter2=value2"
            + "&emptyParam=&parameter3=value3&parameterSeparatedByComma=value41%2Cvalue42"
            + "&multipleParameter=multipleParameterValue1&multipleParameter=multipleParameterValue2"
            + "&pArAmEtErCaSeInSeNsItIvE=value", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("parameter1"));
        paramsToRemove.add(new MyTinyNodeImpl("parameter2"));
        paramsToRemove.add(new MyTinyNodeImpl("parameter3"));
        paramsToRemove.add(new MyTinyNodeImpl("emptyParam"));

        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("parameter1, parameter2, emptyParam", "http://www.example.com/my/path?"
            + "parameterSeparatedByComma=value41%2Cvalue42&multipleParameter=multipleParameterValue1"
            + "&multipleParameter=multipleParameterValue2&pArAmEtErCaSeInSeNsItIvE=value", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("parameterSeparatedByComma"));
        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("parameterSeparatedByComma", "http://www.example.com/my/path?parameter1=value1"
            + "&parameter2=value2&emptyParam=&parameter3=value3&multipleParameter=multipleParameterValue1"
            + "&multipleParameter=multipleParameterValue2&pArAmEtErCaSeInSeNsItIvE=value", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("multipleParameter"));
        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("multipleParameter", "http://www.example.com/my/path?parameter1=value1"
            + "&parameter2=value2&emptyParam=&parameter3=value3"
            + "&parameterSeparatedByComma=value41%2Cvalue42&pArAmEtErCaSeInSeNsItIvE=value", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("parameterCaseInsensitive"));
        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("multipleParameter", "http://www.example.com/my/path?parameter1=value1"
            + "&parameter2=value2&emptyParam=&parameter3=value3&parameterSeparatedByComma=value41%2Cvalue42"
            + "&multipleParameter=multipleParameterValue1&multipleParameter=multipleParameterValue2", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("nonExistingParameter"));
        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, testUrl);
        assertEquals("multipleParameter", "http://www.example.com/my/path?parameter1=value1"
            + "&parameter2=value2&emptyParam=&parameter3=value3&parameterSeparatedByComma=value41%2Cvalue42"
            + "&multipleParameter=multipleParameterValue1&multipleParameter=multipleParameterValue2&pArAmEtErCaSeInSeNsItIvE=value", actualResult);

        paramsToRemove = new ArrayList<>();
        paramsToRemove.add(new MyTinyNodeImpl("nonExistingParameter"));
        actualResult = XslUtilHnap.removeFromUrl(paramsToRemove, "invalid url");
        assertEquals("invalid url", "invalid url", actualResult);


    }

    @Test
    public void testIsEmailAddress() {
        assertTrue(XslUtilHnap.isEmailFormat("o'brian.test@localhost"));
        assertTrue(XslUtilHnap.isEmailFormat("o'brian.test@localhost.com"));

        assertFalse(XslUtilHnap.isEmailFormat("o'brian.test@localhost.com."));
        assertFalse(XslUtilHnap.isEmailFormat("o'brian.test@localhost."));
        assertFalse(XslUtilHnap.isEmailFormat("o'brian.test@"));
        assertFalse(XslUtilHnap.isEmailFormat("o'brian.test"));

    }

    class MyTinyNodeImpl extends TinyNodeImpl {

        private String value;

        public MyTinyNodeImpl(String value) {
            this.value = value;
        }

        @Override
        public int getNodeKind() {
            return 0;
        }

        @Override
        public String getStringValue() {
            return this.value;
        }

        @Override
        public void copy(Receiver receiver, int i, boolean b, int i1) throws XPathException {

        }
    }
}
