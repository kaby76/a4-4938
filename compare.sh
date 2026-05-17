#
set -x
set -e

rm -rf current/bin current/obj
rm -rf pr/bin pr/obj

# Build local copy of antlr4
if [ ! -e current-antlr ]
then
	git clone https://github.com/antlr/antlr4.git current-antlr
	pushd current-antlr
	export MAVEN_OPTS="-Xmx1G"
	mvn -DskipTests install
	cd runtime/CSharp/src
	dotnet build -c Release
	popd
fi
pushd current
bash build.sh
popd

if [ ! -e pr-antlr ]
then
	git clone https://github.com/HarryCordewener/antlr4.git -b feature/csharp-runtime-perf-optimizations pr-antlr
	pushd pr-antlr
	export MAVEN_OPTS="-Xmx1G"
	mvn -DskipTests install
	cd runtime/CSharp/src
	dotnet build -c Release
	popd
fi
pushd pr
bash build.sh
popd

# Run each Test.exe 5 times and collect runtimes (milliseconds)
current_times=()
for i in {1..5}; do
	start=$(date +%s%N)
	pushd current
	./bin/Release/net10.0/Test.exe ../examples/*.cs
	popd
	end=$(date +%s%N)
	current_times+=( $(( (end - start) / 1000000 )) )
done

pr_times=()
for i in {1..5}; do
	start=$(date +%s%N)
	pushd pr
	./bin/Release/net10.0/Test.exe ../examples/*.cs
	popd
	end=$(date +%s%N)
	pr_times+=( $(( (end - start) / 1000000 )) )
done

current_old_times=()
for i in {1..5}; do
	start=$(date +%s%N)
	pushd current
	./bin/Release/net10.0/Test.exe -old ../examples/*.cs
	popd
	end=$(date +%s%N)
	current_old_times+=( $(( (end - start) / 1000000 )) )
done

pr_old_times=()
for i in {1..5}; do
	start=$(date +%s%N)
	pushd pr
	./bin/Release/net10.0/Test.exe -old ../examples/*.cs
	popd
	end=$(date +%s%N)
	pr_old_times+=( $(( (end - start) / 1000000 )) )
done

pr_new_times=()
for i in {1..5}; do
	start=$(date +%s%N)
	pushd pr
	./bin/Release/net10.0/Test.exe -new ../examples/*.cs
	popd
	end=$(date +%s%N)
	pr_new_times+=( $(( (end - start) / 1000000 )) )
done

# Format arrays as Octave vectors
current_vec=$(IFS=','; echo "${current_times[*]}")
pr_vec=$(IFS=','; echo "${pr_times[*]}")
current_old_vec=$(IFS=','; echo "${current_old_times[*]}")
pr_old_vec=$(IFS=','; echo "${pr_old_times[*]}")
pr_new_vec=$(IFS=','; echo "${pr_new_times[*]}")

# Generate bar chart with standard error bars via Octave
octave --no-gui << EOF
current_times     = [${current_vec}];
pr_times          = [${pr_vec}];
current_old_times = [${current_old_vec}];
pr_old_times      = [${pr_old_vec}];
pr_new_times      = [${pr_new_vec}];

n = length(current_times);
means = [mean(current_times), mean(pr_times), mean(current_old_times), mean(pr_old_times), mean(pr_new_times)];
sems  = [std(current_times), std(pr_times), std(current_old_times), std(pr_old_times), std(pr_new_times)] / sqrt(n);

fig = figure('visible', 'off');
hb = bar(means);
set(hb, 'FaceColor', [0.4 0.6 0.9]);
hold on;
he = errorbar(1:5, means, sems, '.k');
set(he, 'LineWidth', 2);
set(gca, 'XTick', 1:5, 'XTickLabel', {'current', 'pr', 'current -old', 'pr -old', 'pr -new'});
ylabel('Time (ms)');
title('Runtime Comparison (n=5, error bars = SEM)');
grid on;
saveas(fig, 'comparison.png');
disp('Saved comparison.png');
disp(['current:      ' num2str(means(1)) ' +/- ' num2str(sems(1)) ' ms']);
disp(['pr:           ' num2str(means(2)) ' +/- ' num2str(sems(2)) ' ms']);
disp(['current -old: ' num2str(means(3)) ' +/- ' num2str(sems(3)) ' ms']);
disp(['pr -old:      ' num2str(means(4)) ' +/- ' num2str(sems(4)) ' ms']);
disp(['pr -new:      ' num2str(means(5)) ' +/- ' num2str(sems(5)) ' ms']);
EOF
