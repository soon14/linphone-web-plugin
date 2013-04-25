/*!
 Linphone Web - Web plugin of Linphone an audio/video SIP phone
 Copyright (C) 2012  Yann Diorcet <yann.diorcet@linphone.org>
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef H_WRAPPERAPI
#define H_WRAPPERAPI

#include <JSAPIAuto.h>
#include "utils.h"

FB_FORWARD_PTR(FactoryAPI)

FB_FORWARD_PTR(WrapperAPI)
class WrapperAPI: public FB::JSAPIAuto {
    friend class FactoryAPI;
private:
    ThreadGroup mThreads;
    
protected:
	FactoryAPIPtr mFactory;
    virtual void setFactory(FactoryAPIPtr factory);
    
    bool mUsed;
	bool mConst;
    
    WrapperAPI(const std::string& description = "<JSAPI-Auto Javascript Object>");
    
    // Thread
    void attachThread(const boost::shared_ptr<boost::thread> &thread);
    void detachThread(boost::thread::id id);
    
    virtual void shutdown();
};

#endif // H_WRAPPERAPI