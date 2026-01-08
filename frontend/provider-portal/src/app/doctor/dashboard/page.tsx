"use client";

import { useState, useEffect } from 'react';
import Head from 'next/head';

// Mock Data (Replace with API calls)
const PATIENTS = [
    { id: 1, name: "Alice Smith", age: 34, lastVisit: "2024-10-15", condition: "Hypertension" },
    { id: 2, name: "Bob Jones", age: 52, lastVisit: "2024-10-20", condition: "Type 2 Diabetes" },
    { id: 3, name: "Carol White", age: 28, lastVisit: "2024-10-22", condition: "Asthma" },
];

export default function DoctorDashboard() {
    const [activeTab, setActiveTab] = useState('appointments');
    const [schedule, setSchedule] = useState({
        Monday: { start: "09:00", end: "17:00", active: true },
        Tuesday: { start: "09:00", end: "17:00", active: true },
        Wednesday: { start: "09:00", end: "17:00", active: true },
        Thursday: { start: "09:00", end: "17:00", active: true },
        Friday: { start: "09:00", end: "13:00", active: true },
    });

    const [saving, setSaving] = useState(false);

    const handleScheduleChange = (day: string, field: string, value: any) => {
        setSchedule(prev => ({
            ...prev,
            [day]: { ...prev[day as keyof typeof schedule], [field]: value }
        }));
    };

    const saveAvailability = async () => {
        setSaving(true);
        // Simulate API call
        setTimeout(() => {
            setSaving(false);
            alert("Availability updated!");
        }, 1000);
    };

    return (
        <div className="min-h-screen bg-gray-50 flex">
            {/* Sidebar */}
            <aside className="w-64 bg-white border-r border-gray-200 hidden md:block">
                <div className="p-6">
                    <span className="text-2xl font-bold text-blue-600">MedX Doctor</span>
                </div>
                <nav className="mt-6 px-4 space-y-2">
                    <button
                        onClick={() => setActiveTab('appointments')}
                        className={`w-full flex items-center px-4 py-2 text-sm font-medium rounded-md ${activeTab === 'appointments' ? 'bg-blue-50 text-blue-700' : 'text-gray-600 hover:bg-gray-50'}`}
                    >
                        Appointments
                    </button>
                    <button
                        onClick={() => setActiveTab('patients')}
                        className={`w-full flex items-center px-4 py-2 text-sm font-medium rounded-md ${activeTab === 'patients' ? 'bg-blue-50 text-blue-700' : 'text-gray-600 hover:bg-gray-50'}`}
                    >
                        My Patients
                    </button>
                    <button
                        onClick={() => setActiveTab('schedule')}
                        className={`w-full flex items-center px-4 py-2 text-sm font-medium rounded-md ${activeTab === 'schedule' ? 'bg-blue-50 text-blue-700' : 'text-gray-600 hover:bg-gray-50'}`}
                    >
                        Availability
                    </button>
                </nav>
            </aside>

            {/* Main Content */}
            <main className="flex-1 p-8 overflow-y-auto">
                <header className="flex justify-between items-center mb-8">
                    <h1 className="text-2xl font-bold text-gray-900">
                        {activeTab === 'appointments' && "Today's Schedule"}
                        {activeTab === 'patients' && "My Patients"}
                        {activeTab === 'schedule' && "Manage Availability"}
                    </h1>
                    <div className="flex items-center space-x-4">
                        <span className="text-sm font-medium text-gray-700">Dr. Sarah Connor</span>
                        <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold">SC</div>
                    </div>
                </header>

                {activeTab === 'appointments' && (
                    <div className="space-y-4">
                        {[1, 2].map((i) => (
                            <div key={i} className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center">
                                <div className="flex items-center space-x-4">
                                    <div className="text-center px-4">
                                        <div className="text-sm font-bold text-gray-500">MON</div>
                                        <div className="text-xl font-bold text-gray-900">12</div>
                                    </div>
                                    <div>
                                        <h3 className="text-lg font-medium text-gray-900">John Doe</h3>
                                        <p className="text-sm text-gray-500">General Checkup • 10:00 AM - 10:30 AM</p>
                                    </div>
                                </div>
                                <div className="flex space-x-2">
                                    <button className="px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100">
                                        View Records
                                    </button>
                                    <button className="px-4 py-2 text-sm font-medium text-green-600 bg-green-50 rounded-lg hover:bg-green-100">
                                        Start Session
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {activeTab === 'patients' && (
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Age</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Condition</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Visit</th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {PATIENTS.map((patient) => (
                                    <tr key={patient.id}>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{patient.name}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{patient.age}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-blue-600 bg-blue-50 rounded-full px-2 inline-block w-fit mt-3">{patient.condition}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{patient.lastVisit}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            <a href="#" className="text-blue-600 hover:text-blue-900">Details</a>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {activeTab === 'schedule' && (
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 max-w-2xl">
                        <h3 className="text-lg font-medium text-gray-900 mb-6">Weekly Availability</h3>
                        <div className="space-y-4">
                            {Object.entries(schedule).map(([day, times]) => (
                                <div key={day} className="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
                                    <div className="flex items-center w-32">
                                        <input
                                            type="checkbox"
                                            checked={times.active}
                                            onChange={(e) => handleScheduleChange(day, 'active', e.target.checked)}
                                            className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                                        />
                                        <span className={`ml-3 text-sm font-medium ${times.active ? 'text-gray-900' : 'text-gray-400'}`}>{day}</span>
                                    </div>
                                    <div className="flex items-center space-x-4">
                                        <input
                                            type="time"
                                            value={times.start}
                                            disabled={!times.active}
                                            onChange={(e) => handleScheduleChange(day, 'start', e.target.value)}
                                            className="block w-32 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm disabled:bg-gray-100 disabled:text-gray-400"
                                        />
                                        <span className="text-gray-500">-</span>
                                        <input
                                            type="time"
                                            value={times.end}
                                            disabled={!times.active}
                                            onChange={(e) => handleScheduleChange(day, 'end', e.target.value)}
                                            className="block w-32 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm disabled:bg-gray-100 disabled:text-gray-400"
                                        />
                                    </div>
                                </div>
                            ))}
                        </div>
                        <div className="mt-6 flex justify-end">
                            <button
                                onClick={saveAvailability}
                                disabled={saving}
                                className="bg-blue-600 text-white px-4 py-2 rounded-md font-medium hover:bg-blue-700 transition"
                            >
                                {saving ? "Saving..." : "Save Changes"}
                            </button>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
