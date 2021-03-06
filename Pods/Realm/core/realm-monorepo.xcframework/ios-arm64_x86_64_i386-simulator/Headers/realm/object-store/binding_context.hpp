////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef BINDING_CONTEXT_HPP
#define BINDING_CONTEXT_HPP

#include <realm/object-store/index_set.hpp>

#include <realm/keys.hpp>

#include <memory>
#include <tuple>
#include <unordered_map>
#include <vector>

namespace realm {
// BindingContext is the extension point for adding binding-specific behavior to
// a SharedRealm. It can be used to store additional data associated with the
// Realm which is needed by the binding, and there are several methods which
// can be overridden to receive notifications of state changes within the Realm.
//
// A simple implementation which lets the user register functions to be
// called on refresh could look like the following:
//
// class BindingContextImplementation : public BindingContext {
// public:
//     // A token returned from add_notification that can be used to remove the
//     // notification later
//     struct token : private std::list<std::function<void ()>>::iterator {
//         token(std::list<std::function<void ()>>::iterator it) : std::list<std::function<void ()>>::iterator(it) { }
//         friend class DelegateImplementation;
//     };
//
//     token add_notification(std::function<void ()> func)
//     {
//         m_registered_notifications.push_back(std::move(func));
//         return token(std::prev(m_registered_notifications.end()));
//     }
//
//     void remove_notification(token entry)
//     {
//         m_registered_notifications.erase(entry);
//     }
//
//     // Override the did_change method to call each registered notification
//     void did_change(std::vector<ObserverState> const&, std::vector<void*> const&, bool) override
//     {
//         // Loop oddly so that unregistering a notification from within the
//         // registered function works
//         for (auto it = m_registered_notifications.begin(); it != m_registered_notifications.end(); ) {
//             (*it++)();
//         }
//     }
//
// private:
//     std::list<std::function<void ()>> m_registered_notifications;
// };
class Realm;
class Schema;
class BindingContext {
public:
    virtual ~BindingContext() = default;

    std::weak_ptr<Realm> realm;

    // Called when the Realm is about to send notifications about Realm,
    // Collection or Object changes. This method will be called even if
    // no notification callbacks have been registered.
    virtual void will_send_notifications() {}

    // Called when the Realm is done sending all change notifications. This method
    // will be called even if no notification callbacks have been registered.
    virtual void did_send_notifications() {}

    // Called by the Realm when refresh called or a notification arrives which
    // is triggered through write transaction committed by itself or a different
    // Realm instance.
    virtual void before_notify() {}

    // Called by the Realm when a write transaction is committed to the file by
    // a different Realm instance (possibly in a different process)
    virtual void changes_available() {}

    struct ObserverState;

    // Override this function if you want to receive detailed information about
    // external changes to a specific set of objects.
    // This is called before each operation which may advance the read
    // transaction to include
    // ObserverStates for each row for which detailed change information is
    // desired.
    virtual std::vector<ObserverState> get_observed_rows()
    {
        return {};
    }

    // Called immediately before the read transaction is advanced if detailed
    // change information was requested (by returning a non-empty array from
    // get_observed_rows()).
    // The observers vector is the vector returned by get_observed_row(),
    // updated with change information. The invalidated vector is a list of the
    // `info` fields of observed rows which will be deleted.
    virtual void will_change(std::vector<ObserverState> const& observers, std::vector<void*> const& invalidated);

    // Called immediately after the read transaction version is advanced. Unlike
    // will_change(), this is called even if detailed change information was not
    // requested or if the Realm is not actually in a read transaction, although
    // both vectors will be empty in that case.
    virtual void did_change(std::vector<ObserverState> const& observers, std::vector<void*> const& invalidated,
                            bool version_changed = true);

    // Called immediately after the corresponding Realm's schema is changed through
    // update_schema()/set_schema_subset() or the schema is changed by another Realm
    // instance. The parameter is a schema reference which is the same as the return
    // value of Realm::schema().
    virtual void schema_did_change(Schema const&) {}

    // Change information for a single field of a row
    struct ColumnInfo {
        // What kind of change occurred?
        // Always Set or None for everything but LinkList columns.
        enum class Kind {
            None,   // No change
            Set,    // The value or entries at `indices` were assigned to
            Insert, // New values were inserted at each of the indices given
            Remove, // Values were removed at each of the indices given
            SetAll  // The entire LinkList has been replaced with a new set of values
        } kind = Kind::None;
        // The indices where things happened for Set, Insert and Remove on
        // LinkList columns. Not used for other types or for None or SetAll.
        IndexSet indices;
    };

    // Information about an observed object in a table
    //
    // Each object which needs detailed change information should have an
    // ObserverState entry in the vector returned from get_observed_rows(), with
    // the initial table and row indexes set (and optionally the info field).
    // The Realm parses the transaction log, and populates the `changes` vector
    // in each ObserverState with information about what changes were made.
    struct ObserverState {
        // Table and object which is observed
        realm::TableKey table_key;
        ObjKey obj_key;

        // Opaque userdata for the delegate's use
        void* info;

        // Populated with information about which columns were changed
        // May be shorter than the actual number of columns if the later columns
        // are not modified
        std::unordered_map<int64_t, ColumnInfo> changes;

        // Simple lexographic ordering
        friend bool operator<(ObserverState const& lft, ObserverState const& rgt)
        {
            return std::tie(lft.table_key, lft.obj_key) < std::tie(rgt.table_key, rgt.obj_key);
        }
    };
};

inline void BindingContext::will_change(std::vector<ObserverState> const&, std::vector<void*> const&) {}
inline void BindingContext::did_change(std::vector<ObserverState> const&, std::vector<void*> const&, bool) {}
} // namespace realm

#endif /* BINDING_CONTEXT_HPP */
