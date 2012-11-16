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

#ifndef H_MACRO
#define H_MACRO

#include <boost/preprocessor/control/if.hpp>
#include <boost/preprocessor/array/elem.hpp>
#include <boost/preprocessor/repetition/enum.hpp>
#include <boost/preprocessor/debug/assert.hpp>
#include <boost/preprocessor/comparison/equal.hpp>
#include <boost/mpl/aux_/preprocessor/token_equal.hpp>

#define __DECLARE_SYNC_N_ASYNC_PARAMMACRO(z, n, data) BOOST_PP_ARRAY_ELEM(n, data) paramater_##n
#define __DECLARE_SYNC_N_ASYNC_USEMACRO(z, n, data) paramater_##n

#define REGISTER_SYNC_N_ASYNC(class, name, funct_name)                                          \
	registerMethod(name, make_method(this, &class::funct_name));                                \
	registerMethod(name "_async", make_method(this, &class::BOOST_PP_CAT(funct_name, _async))); \

#define DECLARE_SYNC_N_ASYNC_SYNC_FCT(class, name, argCount, argList, ret)                        \
	ret name (BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_PARAMMACRO, (argCount, argList)));   \

#define BOOST_MPL_PP_TOKEN_EQUAL_void(x) x

#ifdef CORE_THREADED
#define DECLARE_SYNC_N_ASYNC_THREAD_FCT(class, name, argCount, argList, ret)                                                                                               \
	BOOST_PP_IF(BOOST_PP_EQUAL(argCount, 0),                                                                                                                        \
			void BOOST_PP_CAT(name, _async_thread) (FB::JSObjectPtr callback) {,                                                                                    \
			void BOOST_PP_CAT(name, _async_thread) (BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_PARAMMACRO, (argCount, argList)), FB::JSObjectPtr callback) {)   \
	BOOST_PP_IF(BOOST_MPL_PP_TOKEN_EQUAL(ret, void),                                                                                                                \
		name(BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_USEMACRO, NULL));                                                                                       \
		callback->InvokeAsync("", FB::variant_list_of(shared_from_this()));,                                                                                        \
		ret value = name(BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_USEMACRO, NULL));                                                                           \
		callback->InvokeAsync("", FB::variant_list_of(shared_from_this())(value));)                                                                                 \
		m_threads->remove_thread(boost::this_thread::get_id());                                                                                                     \
	}                                                                                                                                                               \

#define DECLARE_SYNC_N_ASYNC_ASYNC_FCT(class, name, argCount, argList)                                                                                                     \
	BOOST_PP_IF(BOOST_PP_EQUAL(argCount, 0),                                                                                                                        \
			void BOOST_PP_CAT(name, _async) (FB::JSObjectPtr callback) {,                                                                                           \
			void BOOST_PP_CAT(name, _async) (BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_PARAMMACRO, (argCount, argList)), FB::JSObjectPtr callback) {)          \
		m_threads->create_thread(boost::bind(&class::BOOST_PP_CAT(name, _async_thread), this,                                                                       \
		BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_USEMACRO, NULL)                                                                                              \
		BOOST_PP_IF(BOOST_PP_NOT_EQUAL(argCount, 0), BOOST_PP_COMMA, BOOST_PP_EMPTY)()                                                                              \
		callback));                                                                                                                                                 \
	}                                                                                                                                                               \

#else
#define DECLARE_SYNC_N_ASYNC_ASYNC_FCT(class, name, argCount, argList, ret)                                                                                                \
	BOOST_PP_IF(BOOST_PP_EQUAL(argCount, 0),                                                                                                                        \
			void BOOST_PP_CAT(name, _async) (FB::JSObjectPtr callback) {,                                                                                           \
			void BOOST_PP_CAT(name, _async) (BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_PARAMMACRO, (argCount, argList)), FB::JSObjectPtr callback) {)          \
	BOOST_PP_IF(BOOST_MPL_PP_TOKEN_EQUAL(ret, void),                                                                                                                \
		name(BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_USEMACRO, (argCount, argList)));                                                                        \
		callback->InvokeAsync("", FB::variant_list_of(shared_from_this()));,                                                                                        \
		ret value = name(BOOST_PP_ENUM(argCount, __DECLARE_SYNC_N_ASYNC_USEMACRO, (argCount, argList)));                                                            \
		callback->InvokeAsync("", FB::variant_list_of(shared_from_this())(value));)                                                                                 \
	}                                                                                                                                                               \

#endif //CORE_THREADED
#ifdef CORE_THREADED
#define DECLARE_SYNC_N_ASYNC(class, name, argCount, argList, ret)          \
	DECLARE_SYNC_N_ASYNC_SYNC_FCT(class, name, argCount, argList, ret)     \
	DECLARE_SYNC_N_ASYNC_THREAD_FCT(class, name, argCount, argList, ret)   \
	DECLARE_SYNC_N_ASYNC_ASYNC_FCT(class, name, argCount, argList)         \

#else
#define DECLARE_SYNC_N_ASYNC(class, name, argCount, argList, ret)          \
	DECLARE_SYNC_N_ASYNC_SYNC_FCT(class, name, argCount, argList, ret)     \
	DECLARE_SYNC_N_ASYNC_ASYNC_FCT(class, name, argCount, argList, ret)    \

#endif //CORE_THREADED

#endif // H_MACRO
