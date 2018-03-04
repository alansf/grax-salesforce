/* ---------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * ---------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * ---------------------------------------------------------------------
 *                      Support@Grax.io
 *                      https://grax.io
 *          https://github.com/HardingPoint/GRAXForSFDC
 *   https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * ---------------------------------------------------------------------*/

public class GRAXConnect {
    public string getPropURLToDisplay() { 
        string salesforceURL = 'https://graphconnect.hardingpoint.com?sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
        return salesforceURL;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
}