import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Users, ShoppingCart, DollarSign, Package } from 'lucide-react';
import api from './api';

const StatCard = ({ title, value, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-lg shadow-md flex items-center">
        <div className={`p-4 rounded-full ${color} mr-4`}>
            <Icon className="text-white" size={24} />
        </div>
        <div>
            <h3 className="text-gray-500 text-sm font-medium">{title}</h3>
            <p className="text-2xl font-bold text-gray-800">{value}</p>
        </div>
    </div>
);

const Dashboard = () => {
    const [stats, setStats] = useState({ users: 0, orders: 0, revenue: 0, products: 0 });
    const [chartData, setChartData] = useState([]);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const res = await api.get('/admin/stats');
                setStats(res.data);
                // Keep chart mock data for now as we didn't implement time-series aggregation in backend yet
                setChartData([
                    { name: 'Mon', orders: 4 },
                    { name: 'Tue', orders: 7 },
                    { name: 'Wed', orders: 2 },
                    { name: 'Thu', orders: 9 },
                    { name: 'Fri', orders: 12 },
                    { name: 'Sat', orders: 15 },
                    { name: 'Sun', orders: 10 },
                ]);
            } catch (e) {
                console.error("Failed to fetch stats", e);
            }
        };
        fetchStats();
    }, []);

    return (
        <div className="p-6 bg-gray-100 min-h-screen">
            <h1 className="text-3xl font-bold mb-8 text-gray-800">Admin Dashboard</h1>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard title="Total Users" value={stats.users} icon={Users} color="bg-blue-500" />
                <StatCard title="Total Orders" value={stats.orders} icon={ShoppingCart} color="bg-green-500" />
                <StatCard title="Total Revenue" value={`₹${stats.revenue}`} icon={DollarSign} color="bg-yellow-500" />
                <StatCard title="Active Products" value={stats.products} icon={Package} color="bg-purple-500" />
            </div>

            {/* Charts */}
            <div className="bg-white p-6 rounded-lg shadow-md">
                <h2 className="text-xl font-bold mb-4 text-gray-700">Orders Overview</h2>
                <div className="h-80">
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={chartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis />
                            <Tooltip />
                            <Legend />
                            <Bar dataKey="orders" fill="#3b82f6" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
