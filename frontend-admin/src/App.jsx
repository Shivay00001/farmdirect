import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { LayoutDashboard, Users as UsersIcon } from 'lucide-react';
import Dashboard from './Dashboard';
import Users from './Users';

function App() {
    return (
        <Router>
            <div className="flex min-h-screen bg-gray-100">
                {/* Sidebar */}
                <div className="w-64 bg-white shadow-md">
                    <div className="p-6">
                        <h1 className="text-2xl font-bold text-green-600">FarmDirect</h1>
                    </div>
                    <nav className="mt-6">
                        <Link to="/" className="flex items-center px-6 py-3 text-gray-700 hover:bg-green-50 hover:text-green-600">
                            <LayoutDashboard size={20} className="mr-3" />
                            Dashboard
                        </Link>
                        <Link to="/users" className="flex items-center px-6 py-3 text-gray-700 hover:bg-green-50 hover:text-green-600">
                            <UsersIcon size={20} className="mr-3" />
                            Users
                        </Link>
                    </nav>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-auto">
                    <Routes>
                        <Route path="/" element={<Dashboard />} />
                        <Route path="/users" element={<Users />} />
                    </Routes>
                </div>
            </div>
        </Router>
    );
}

export default App;
